<?php

declare(strict_types = 1);

namespace SiestaTest\End2End\Reverse\Generated;

use Siesta\Database\ConnectionFactory;
use Siesta\Database\Escaper;
use Siesta\Database\ResultSet;
use Siesta\Util\ArrayUtil;

class ExtLogEntriesService
{

    /**
     * @var ExtLogEntriesService
     */
    protected static $instance;

    /**
     * 
     * @return ExtLogEntriesService
     */
    public static function getInstance() : ExtLogEntriesService
    {
        if (self::$instance === null) {
            self::$instance = new ExtLogEntriesService();
        }
        return self::$instance;
    }

    /**
     * @param int $id
     * @param string $connectionName
     * 
     * @return ExtLogEntries|null
     */
    public function getEntityByPrimaryKey(int $id = null, string $connectionName = null)
    {
        if ($id === null) {
            return null;
        }
        $id = Escaper::quoteInt($id);
        $entityList = $this->executeStoredProcedure("CALL ext_log_entries_SB_PK($id)", $connectionName);
        return ArrayUtil::getFromArray($entityList, 0);
    }

    /**
     * @param int $id
     * @param string $connectionName
     * 
     * @return void
     */
    public function deleteEntityByPrimaryKey(int $id, string $connectionName = null)
    {
        $connection = ConnectionFactory::getConnection($connectionName);
        $id = Escaper::quoteInt($id);
        $connection->execute("CALL ext_log_entries_DB_PK($id)");
    }

    /**
     * 
     * @return ExtLogEntries
     */
    public function newInstance() : ExtLogEntries
    {
        return new ExtLogEntries();
    }

    /**
     * @param ResultSet $resultSet
     * 
     * @return ExtLogEntries
     */
    public function createInstanceFromResultSet(ResultSet $resultSet) : ExtLogEntries
    {
        $entity = $this->newInstance();
        $entity->fromResultSet($resultSet);
        return $entity;
    }

    /**
     * @param string $spCall
     * @param string $connectionName
     * 
     * @return ExtLogEntries[]
     */
    public function executeStoredProcedure(string $spCall, string $connectionName = null) : array
    {
        $connection = ConnectionFactory::getConnection($connectionName);
        $entityList = [];
        $resultSet = $connection->executeStoredProcedure($spCall);
        while ($resultSet->hasNext()) {
            $entityList[] = $this->createInstanceFromResultSet($resultSet);
        }
        $resultSet->close();
        return $entityList;
    }

    /**
     * @param ExtLogEntries[] $entityList
     * @param string $connectionName
     * 
     * @return void
     */
    public function batchSave(array $entityList, string $connectionName = null)
    {
        $batchCall = "";
        foreach ($entityList as $entity) {
            $batchCall .= $entity->createSaveStoredProcedureCall();
        }
        $connection = ConnectionFactory::getConnection($connectionName);
        $connection->execute($batchCall);
    }

}