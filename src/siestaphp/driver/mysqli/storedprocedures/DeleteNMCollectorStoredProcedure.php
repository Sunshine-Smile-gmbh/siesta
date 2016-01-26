<?php

namespace siestaphp\driver\mysqli\storedprocedures;

use Codeception\Util\Debug;
use siestaphp\datamodel\collector\CollectorGeneratorSource;
use siestaphp\datamodel\collector\NMMapping;
use siestaphp\datamodel\DatabaseColumn;
use siestaphp\datamodel\entity\EntityGeneratorSource;
use siestaphp\datamodel\reference\ReferencedColumnSource;

/**
 * Class SelectStoredProcedure
 * @package siestaphp\driver\mysqli\storedprocedures
 */
class DeleteNMCollectorStoredProcedure extends MySQLStoredProcedureBase
{

    const SQL_DELETE = "DELETE FROM %s WHERE %s;";

    /**
     * @var EntityGeneratorSource
     */
    protected $mappingEntity;

    /**
     * @var EntityGeneratorSource
     */
    protected $foreignEntity;

    /**
     * @param EntityGeneratorSource $source
     * @param CollectorGeneratorSource $collectorGeneratorSource
     * @param bool $replication
     */
    public function __construct(EntityGeneratorSource $source, CollectorGeneratorSource $collectorGeneratorSource, $replication)
    {
        parent::__construct($source, $replication);

        $this->mappingEntity = $collectorGeneratorSource->getMappingClassEntity();

        $this->name = $collectorGeneratorSource->getNMDeleteStoredProcedueName();

        $this->buildElements();
    }

    /**
     * @return void
     */
    protected function buildElements()
    {
        $this->modifies = false;

        $this->determineTableNames();

        $this->buildSignature();

        $this->buildStatement();

    }

    /**
     * @return void
     */
    protected function buildSignature()
    {
        $signatureList = [];
        foreach ($this->entitySource->getPrimaryKeyColumns() as $column) {
            $signatureList[] = $this->buildSignatureParameterPart($column);
        }

        $this->signature = $this->buildSignatureSnippet($signatureList);
    }

    /**
     * @return void
     */
    protected function buildStatement()
    {

        $mappingTableName = $this->mappingEntity->getTable();
        $whereList = [];

        foreach ($this->entitySource->getPrimaryKeyColumns() as $pkColumn) {
            $mappingColumn = $this->getCorrespondingMappingColumn($this->entitySource->getTable(), $pkColumn);
            $whereList[] = $this->buildTableColumnNameSnippet($mappingTableName, $mappingColumn) . " = " . $pkColumn->getSQLParameterName();
        }
        $where = $this->buildWhereSnippet($whereList);

        $this->statement = sprintf(self::SQL_DELETE, $mappingTableName, $where);
    }

    /**
     * @param $tableName
     * @param DatabaseColumn $column
     *
     * @return ReferencedColumnSource
     */
    protected function getCorrespondingMappingColumn($tableName, DatabaseColumn $column)
    {
        Debug::debug("searching for table " . $tableName);
        foreach ($this->mappingEntity->getReferenceSourceList() as $reference) {
            Debug::debug("    # found" . $reference->getForeignTable());

            if ($reference->getForeignTable() !== $tableName) {
                continue;
            }
            foreach ($reference->getReferencedColumnList() as $referencedColumn) {
                if ($referencedColumn->getReferencedDatabaseName() === $column->getDatabaseName()) {
                    return $referencedColumn;
                }
            }

        }
    }

    /**
     * @param string $tableName
     * @param DatabaseColumn $column
     *
     * @return string
     */
    protected function buildTableColumnNameSnippet($tableName, DatabaseColumn $column)
    {
        return $this->quote($tableName) . "." . $this->quote($column->getDatabaseName());
    }



}