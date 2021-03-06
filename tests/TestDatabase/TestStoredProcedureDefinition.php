<?php

namespace SiestaTest\TestDatabase;

use Siesta\Database\StoredProcedureDefinition;

class TestStoredProcedureDefinition implements StoredProcedureDefinition
{

    /**
     * @var string
     */
    private $name;

    /**
     * @var
     */
    private $dropStatement;

    /**
     * @var
     */
    private $createStatement;

    /**
     * TestStoredProcedureDefinition constructor.
     * @param null $name
     * @param null $dropStatement
     * @param null $createStatement
     */
    public function __construct($name = "", $dropStatement = null, $createStatement = null)
    {
        $this->name = $name;
        $this->dropStatement = $dropStatement;
        $this->createStatement = $createStatement;
    }

    /**
     * @return null|string
     */
    public function getDropProcedureStatement()
    {
        return $this->dropStatement;
    }

    /**
     * @return null|string
     */
    public function getCreateProcedureStatement()
    {
        return $this->createStatement;
    }

    /**
     * @return string
     */
    public function getProcedureName() : string
    {
        return $this->name;
    }

}