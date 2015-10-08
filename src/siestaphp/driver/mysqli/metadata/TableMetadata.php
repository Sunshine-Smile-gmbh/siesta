<?php

namespace siestaphp\driver\mysqli\metadata;

use siestaphp\datamodel\attribute\AttributeSource;
use siestaphp\datamodel\collector\CollectorSource;
use siestaphp\datamodel\entity\EntitySource;
use siestaphp\datamodel\index\IndexSource;
use siestaphp\datamodel\reference\ReferenceSource;
use siestaphp\datamodel\storedprocedure\StoredProcedureSource;
use siestaphp\driver\Driver;
use siestaphp\driver\mysqli\MySQLDriver;

/**
 * Class TableMetadata
 * @package siestaphp\driver\mysqli\metadata
 */
class TableMetadata implements EntitySource
{
    const SP_GET_COLUMN_DETAILS = "CALL `SIESTA_GET_COLUMN_DETAILS` ('%s','%s')";
    const SP_GET_FK_DETAILS = "CALL `SIESTA_GET_FOREIGN_KEY_DETAILS` ('%s','%s')";

    const SQL_GET_INDEX_LIST = "SELECT S.* FROM INFORMATION_SCHEMA.STATISTICS AS S WHERE S.TABLE_SCHEMA = '%s' AND S.TABLE_NAME = '%s';";

    /**
     * @var string
     */
    protected $tableName;

    /**
     * @var string
     */
    protected $targetPath;

    /**
     * @var string
     */
    protected $targetNamespace;

    /**
     * @var MySQLDriver
     */
    protected $driver;

    /**
     * @var AttributeMetaData[]
     */
    protected $attributeMetaDataList;

    /**
     * @var ReferenceMetaData[]
     */
    protected $referenceMetaDataList;

    /**
     * @var IndexMetaData[]
     */
    protected $indexMetaList;

    /**
     * @param Driver $driver
     * @param TableDTO $tableDTO
     * @param string $targetPath
     * @param string $targetNamespace
     */
    public function __construct(Driver $driver, TableDTO $tableDTO, $targetPath, $targetNamespace)
    {
        $this->tableName = $tableDTO->name;
        $this->targetPath = $targetPath;
        $this->targetNamespace = $targetNamespace;

        $this->driver = $driver;

        $this->attributeMetaDataList = array();
        $this->referenceMetaDataList = array();
        $this->indexMetaList = array();

        $this->extractReferenceData();

        $this->extractColumns();

        $this->extractIndexData();
    }

    /**
     * extracts columns from table and create AttributeMetaData or ReferenceMetaData objects
     */
    protected function extractColumns()
    {

        $sql = sprintf(self::SP_GET_COLUMN_DETAILS, $this->driver->getDatabase(), $this->tableName);

        $resultSet = $this->driver->executeStoredProcedure($sql);

        while ($resultSet->hasNext()) {
            $columnName = $resultSet->getStringValue(AttributeMetaData::COLUMN_NAME);
            $reference = $this->getReferenceByColumnName($columnName);
            if ($reference !== null) {
                $reference->updateFromColumn($resultSet);
            } else {
                $this->attributeMetaDataList[] = new AttributeMetaData($resultSet);
            }
        }

        $resultSet->close();
    }

    /**
     * reads foreign key constraints and enriches ReferenceMetaData objects
     */
    protected function extractReferenceData()
    {
        $sql = sprintf(self::SP_GET_FK_DETAILS, $this->driver->getDatabase(), $this->tableName);

        $resultSet = $this->driver->executeStoredProcedure($sql);

        while ($resultSet->hasNext()) {
            $constraintName = ReferenceMetaData::getConstraintNameFromResultSet($resultSet);
            $referenceMetaData = $this->getReferenceByConstraintName($constraintName);
            if ($referenceMetaData) {
                $referenceMetaData->updateFromConstraint($resultSet);
            } else {
                $this->referenceMetaDataList[] = new ReferenceMetaData($resultSet);
            }
        }

        $resultSet->close();
    }

    /**
     * @param $constraintName
     *
     * @return null|ReferenceMetaData
     */
    private function getReferenceByConstraintName($constraintName)
    {
        foreach ($this->referenceMetaDataList as $referenceMetaData) {
            if ($referenceMetaData->getConstraintName() === $constraintName) {
                return $referenceMetaData;
            }
        }
        return null;
    }

    /**
     * retrieves a ReferenceMetaData by column name
     *
     * @param string $columnName
     *
     * @return ReferenceMetaData
     */
    protected function getReferenceByColumnName($columnName)
    {
        foreach ($this->referenceMetaDataList as $referenceMetaData) {
            if ($referenceMetaData->usesColumn($columnName)) {
                return $referenceMetaData;
            }
        }
        return null;
    }

    protected function extractIndexData()
    {
        $sql = sprintf(self::SQL_GET_INDEX_LIST, $this->driver->getDatabase(), $this->tableName);

        $resultSet = $this->driver->query($sql);
        while ($resultSet->hasNext()) {
            if (!IndexMetaData::isValidIndex($resultSet)) {
                continue;
            }
            $indexName = IndexMetaData::getIndexNameFromResultSet($resultSet);
            $index = $this->getIndexByName($indexName);
            if ($index) {
                $index->addIndexPart($resultSet);
            } else {
                $this->indexMetaList[] = new IndexMetaData($resultSet);
            }
        }
    }

    /**
     * @param $indexName
     *
     * @return null|IndexMetaData
     */
    protected function getIndexByName($indexName)
    {
        foreach ($this->indexMetaList as $indexMetaData) {
            if ($indexMetaData->getName() === $indexName) {
                return $indexMetaData;
            }
        }
        return null;
    }

    /**
     * @return AttributeSource[]
     */
    public function getAttributeSourceList()
    {
        return $this->attributeMetaDataList;
    }

    /**
     * @return ReferenceSource[]
     */
    public function getReferenceSourceList()
    {
        return $this->referenceMetaDataList;
    }

    /**
     * @return StoredProcedureSource[]
     */
    public function getStoredProcedureSourceList()
    {
        return array();
    }

    /**
     * @return CollectorSource[]
     */
    public function getCollectorSourceList()
    {
        return array();
    }

    /**
     * @return IndexSource[]
     */
    public function getIndexSourceList()
    {
        return $this->indexMetaList;
    }

    /**
     * @return string
     */
    public function getClassName()
    {
        return $this->tableName;
    }

    /**
     * @return string
     */
    public function getClassNamespace()
    {
        return $this->targetNamespace;
    }

    /**
     * @return string
     */
    public function getConstructorClass()
    {
        return "";
    }

    /**
     * @return string
     */
    public function getConstructorNamespace()
    {
        return "";
    }

    /**
     * @return string
     */
    public function getTable()
    {
        return $this->tableName;
    }

    /**
     * @return boolean
     */
    public function isDelimit()
    {
        return false;
    }

    /**
     * @return string
     */
    public function getTargetPath()
    {
        return "sql/gen";
    }

}
