<?php

declare(strict_types = 1);

namespace SiestaTest\End2End\Collection\Generated;

use Siesta\Contract\ArraySerializable;
use Siesta\Contract\CycleDetector;
use Siesta\Database\ConnectionFactory;
use Siesta\Database\Escaper;
use Siesta\Database\ResultSet;
use Siesta\Sequencer\SequencerFactory;
use Siesta\Util\ArrayAccessor;
use Siesta\Util\ArrayUtil;
use Siesta\Util\DefaultCycleDetector;
use Siesta\Util\StringUtil;

class CartUUID implements ArraySerializable
{

    const TABLE_NAME = "CartUUID";

    const COLUMN_ID = "id";

    const COLUMN_NAME = "name";

    /**
     * @var bool
     */
    protected $_existing;

    /**
     * @var array
     */
    protected $_rawJSON;

    /**
     * @var array
     */
    protected $_rawSQLResult;

    /**
     * @var string
     */
    protected $id;

    /**
     * @var string
     */
    protected $name;

    /**
     * @var CartItemUUID[]
     */
    protected $cartItem;

    /**
     * 
     */
    public function __construct()
    {
        $this->_existing = false;
    }

    /**
     * @param string $connectionName
     * 
     * @return string
     */
    public function createSaveStoredProcedureCall(string $connectionName = null) : string
    {
        $spCall = ($this->_existing) ? "CALL CartUUID_U(" : "CALL CartUUID_I(";
        $connection = ConnectionFactory::getConnection($connectionName);
        $this->getId(true, $connectionName);
        return $spCall . Escaper::quoteString($connection, $this->id) . ',' . Escaper::quoteString($connection, $this->name) . ');';
    }

    /**
     * @param bool $cascade
     * @param CycleDetector $cycleDetector
     * @param string $connectionName
     * 
     * @return void
     */
    public function save(bool $cascade = false, CycleDetector $cycleDetector = null, string $connectionName = null)
    {
        $connection = ConnectionFactory::getConnection($connectionName);
        if ($cycleDetector === null) {
            $cycleDetector = new DefaultCycleDetector();
        }
        if (!$cycleDetector->canProceed(self::TABLE_NAME, $this)) {
            return;
        }
        $call = $this->createSaveStoredProcedureCall($connectionName);
        $connection->execute($call);
        $this->_existing = true;
        if (!$cascade) {
            return;
        }
        if ($this->cartItem !== null) {
            foreach ($this->cartItem as $entity) {
                $entity->save($cascade, $cycleDetector, $connectionName);
            }
        }
    }

    /**
     * @param ResultSet $resultSet
     * 
     * @return void
     */
    public function fromResultSet(ResultSet $resultSet)
    {
        $this->_existing = true;
        $this->_rawSQLResult = $resultSet->getNext();
        $this->id = $resultSet->getStringValue("id");
        $this->name = $resultSet->getStringValue("name");
    }

    /**
     * @param string $key
     * 
     * @return string|null
     */
    public function getAdditionalColumn(string $key)
    {
        return ArrayUtil::getFromArray($this->_rawSQLResult, $key);
    }

    /**
     * @param string $connectionName
     * 
     * @return void
     */
    public function delete(string $connectionName = null)
    {
        $connection = ConnectionFactory::getConnection($connectionName);
        $id = Escaper::quoteString($connection, $this->id);
        $connection->execute("CALL CartUUID_DB_PK($id)");
        $this->_existing = false;
    }

    /**
     * @param array $data
     * 
     * @return void
     */
    public function fromArray(array $data)
    {
        $this->_rawJSON = $data;
        $arrayAccessor = new ArrayAccessor($data);
        $this->setId($arrayAccessor->getStringValue("id"));
        $this->setName($arrayAccessor->getStringValue("name"));
        $this->_existing = ($this->id !== null);
        $cartItemArray = $arrayAccessor->getArray("cartItem");
        if ($cartItemArray !== null) {
            foreach ($cartItemArray as $entityArray) {
                $cartItem = CartItemUUIDService::getInstance()->newInstance();
                $cartItem->fromArray($entityArray);
                $this->addToCartItem($cartItem);
            }
        }
    }

    /**
     * @param CycleDetector $cycleDetector
     * 
     * @return array|null
     */
    public function toArray(CycleDetector $cycleDetector = null)
    {
        if ($cycleDetector === null) {
            $cycleDetector = new DefaultCycleDetector();
        }
        if (!$cycleDetector->canProceed(self::TABLE_NAME, $this)) {
            return null;
        }
        $result = [
            "id" => $this->getId(),
            "name" => $this->getName()
        ];
        $result["cartItem"] = [];
        if ($this->cartItem !== null) {
            foreach ($this->cartItem as $entity) {
                $result["cartItem"][] = $entity->toArray($cycleDetector);
            }
        }
        return $result;
    }

    /**
     * @param string $jsonString
     * 
     * @return void
     */
    public function fromJSON(string $jsonString)
    {
        $this->fromArray(json_decode($jsonString, true));
    }

    /**
     * @param CycleDetector $cycleDetector
     * 
     * @return string
     */
    public function toJSON(CycleDetector $cycleDetector = null) : string
    {
        return json_encode($this->toArray($cycleDetector));
    }

    /**
     * @param bool $generateKey
     * @param string $connectionName
     * 
     * @return string|null
     */
    public function getId(bool $generateKey = false, string $connectionName = null)
    {
        if ($generateKey && $this->id === null) {
            $this->id = SequencerFactory::nextSequence("uuid", self::TABLE_NAME, $connectionName);
        }
        return $this->id;
    }

    /**
     * @param string $id
     * 
     * @return void
     */
    public function setId(string $id = null)
    {
        $this->id = StringUtil::trimToNull($id, 36);
    }

    /**
     * 
     * @return string|null
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @param string $name
     * 
     * @return void
     */
    public function setName(string $name = null)
    {
        $this->name = StringUtil::trimToNull($name, 100);
    }

    /**
     * @param bool $forceReload
     * @param string $connectionName
     * 
     * @return CartItemUUID[]
     */
    public function getCartItem(bool $forceReload = false, string $connectionName = null) : array
    {
        if ($this->cartItem === null || $forceReload) {
            $this->cartItem = CartItemUUIDService::getInstance()->getEntityByCartReference($this->getId(true, $connectionName), $connectionName);
        }
        return $this->cartItem;
    }

    /**
     * @param string $connectionName
     * 
     * @return void
     */
    public function deleteAllCartItem(string $connectionName = null)
    {
        CartItemUUIDService::getInstance()->deleteEntityByCartReference($this->getId(true, $connectionName), $connectionName);
        $this->cartItem = null;
    }

    /**
     * @param CartItemUUID $entity
     * 
     * @return void
     */
    public function addToCartItem(CartItemUUID $entity)
    {
        $entity->setCart($this);
        if ($this->cartItem === null) {
            $this->cartItem = [];
        }
        $this->cartItem[] = $entity;
    }

    /**
     * @param CartUUID $entity
     * 
     * @return bool
     */
    public function arePrimaryKeyIdentical(CartUUID $entity = null) : bool
    {
        if ($entity === null) {
            return false;
        }
        return $this->getId() === $entity->getId();
    }

}