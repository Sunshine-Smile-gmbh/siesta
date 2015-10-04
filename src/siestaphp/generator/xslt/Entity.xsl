<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="utf-8"/>


    <xsl:template match="/">&lt;?php

        <xsl:if test="/entity/@namespace != ''">
            namespace <xsl:value-of select="/entity/@namespace"/>;
        </xsl:if>

        <xsl:if test="/entity/@dateTimeInUse = 'true'">
            use siestaphp\runtime\DateTime;
            use siestaphp\runtime\Factory;
        </xsl:if>
        use siestaphp\runtime\ArrayAccessor;
        use siestaphp\runtime\HttpRequest;
        use siestaphp\runtime\ServiceLocator;
        use siestaphp\runtime\Passport;
        use siestaphp\runtime\ORMEntity;
        use siestaphp\driver\ResultSet;
        use siestaphp\util\StringUtil;
        use siestaphp\util\Util;

        <xsl:for-each select="/entity/referenceUseList/referenceUse">
            use <xsl:value-of select="@use"/>;
        </xsl:for-each>

        /**
         * Class <xsl:value-of select="/entity/@name"/> ORM for table <xsl:value-of select="/entity/@table"/>
         * @package <xsl:value-of select="/entity/@namespace"/>
         */
        class <xsl:value-of select="/entity/@name"/> implements ORMEntity {

            <xsl:call-template name="getEntityByPrimaryKey"/>

            <xsl:call-template name="referenceFinder"/>

            <xsl:call-template name="referenceDeleter"/>

            <xsl:call-template name="deleteByPrimaryKey"/>

            <xsl:call-template name="customStoredProcedures"/>

            <xsl:call-template name="executeStoredProcedure"/>

            <xsl:call-template name="createInstanceFromResultSet"/>

            <xsl:call-template name="batchSaver"/>

            <xsl:call-template name="attributes"/>

            <xsl:call-template name="constructor"/>

            <xsl:call-template name="validate"/>

            <xsl:call-template name="save"/>

            <xsl:call-template name="fromResultSet"/>

            <xsl:call-template name="fromHttpRequest"/>

            <xsl:call-template name="fromArray"/>

            <xsl:call-template name="toArray"/>

            <xsl:call-template name="linkRelations"/>

            <xsl:call-template name="attributeGetterSetter"/>

            <xsl:call-template name="referenceGetterSetter"/>

            <xsl:call-template name="collectorGetterSetter"/>

            <xsl:call-template name="arePrimaryKeyIdentical"/>
        }

    </xsl:template>


    <xsl:template name="getEntityByPrimaryKey">
        /**
        <xsl:for-each select="/entity/attributeList/attribute[@primaryKey = 'true']">
          * @param <xsl:value-of select="@type"/> $<xsl:value-of select="@name"/>
        </xsl:for-each>
         * @return <xsl:value-of select="/entity/@constructClass"/>
         */
        public static function getEntityByPrimaryKey(<xsl:value-of select="/entity/@findByPKSignature"/>)
        {
            if (<xsl:for-each select="/entity/attributeList/attribute[@primaryKey = 'true']">!$<xsl:value-of select="@name"/><xsl:if test="position() != last()"> or </xsl:if></xsl:for-each>) {
                return null;
            }
            $driver = ServiceLocator::getDriver();
            <xsl:for-each select="/entity/attributeList/attribute[@primaryKey = 'true']">
                $<xsl:value-of select="@name"/> = $driver->escape($<xsl:value-of select="@name"/>);
            </xsl:for-each>

            $resultList = self::executeStoredProcedure("CALL <xsl:value-of select="/entity/standardStoredProcedures/@findByPrimaryKey"/>(<xsl:value-of select="/entity/@storedProcedureCallSignature"/>)");
            return Util::getFromIndex($resultList, 0);
        }
    </xsl:template>

    <xsl:template name="referenceFinder">
        <xsl:for-each select="/entity/referenceList/reference">
            /**
             * <xsl:for-each select="columnList/column">
             * @param <xsl:value-of select="@type"/> $<xsl:value-of select="@name"/>
             * </xsl:for-each>
             * @return <xsl:value-of select="/entity/@constructClass"/>[]
             */
            public static function getEntityBy<xsl:value-of select="@methodName"/>Reference(
            <xsl:for-each select="columnList/column">
                $<xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each> ) {

            return self::executeStoredProcedure("CALL <xsl:value-of select="@spFinderName"/>("
                <xsl:for-each select="columnList/column">
                ."'$<xsl:value-of select="@name"/>'"<xsl:if test="position() != last()">.","</xsl:if>
                </xsl:for-each>.")");
            }
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="referenceDeleter">
        <xsl:for-each select="/entity/referenceList/reference">
            /**
            * <xsl:for-each select="columnList/column">
            * @param <xsl:value-of select="@type"/> $<xsl:value-of select="@name"/>
            * </xsl:for-each>
            */
            public static function deleteEntityBy<xsl:value-of select="@methodName"/>Reference(
            <xsl:for-each select="columnList/column">
                $<xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>) {


            $driver = ServiceLocator::getDriver();

            <xsl:for-each select="columnList/column">
                $<xsl:value-of select="@name"/> = $driver->escape($<xsl:value-of select="@name"/>);
            </xsl:for-each>

            $driver->execute("CALL <xsl:value-of select="@spDeleterName"/>("
            <xsl:for-each select="columnList/column">
                ."'$<xsl:value-of select="@name"/>'"
                <xsl:if test="position() != last()">.","</xsl:if>
            </xsl:for-each>
            .")");
            }
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="deleteByPrimaryKey">
        /**
        <xsl:for-each select="/entity/attributeList/attribute">
            <xsl:if test="@primaryKey = 'true'">
                * @param <xsl:value-of select="@type"/> $<xsl:value-of select="@name"/>
            </xsl:if>
        </xsl:for-each>
        * @return <xsl:value-of select="/entity/@constructClass"/>
        */
        public static function deleteEntityByPrimaryKey(<xsl:value-of select="/entity/@findByPKSignature"/>)
        {

        $driver = ServiceLocator::getDriver();
        <xsl:for-each select="/entity/attributeList/attribute">
            <xsl:if test="@primaryKey = 'true'">
                $<xsl:value-of select="@name"/> = $driver->escape($<xsl:value-of select="@name"/>);
            </xsl:if>
        </xsl:for-each>
        $driver->execute("CALL <xsl:value-of select="/entity/standardStoredProcedures/@deleteByPrimaryKey"/>(<xsl:value-of select="/entity/@storedProcedureCallSignature"/>)");
        }
    </xsl:template>


    <xsl:template name="customStoredProcedures">
        <xsl:for-each select="/entity/storedProcedureList/storedProcedure">
            /**
             * <xsl:for-each select="parameter">
             *     @param <xsl:value-of select="@type"/> $<xsl:value-of select="@name"/>
             * </xsl:for-each>
                <xsl:choose>
                    <xsl:when test="@resultType='single'">
                        * @return <xsl:value-of select="/entity/@constructClass"/>
                    </xsl:when>
                    <xsl:when test="@resultType='list'">
                        * @return <xsl:value-of select="/entity/@constructClass"/>[]
                    </xsl:when>
                    <xsl:when test="@resultType='resultset'">
                        * @return ResultSet
                    </xsl:when>
                </xsl:choose>
             */
            public static function <xsl:value-of select="@name"/>(
            <xsl:for-each select="parameter">
                $<xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            ) {
                $driver = ServiceLocator::getDriver();
                <xsl:for-each select="parameter">
                    $<xsl:value-of select="@name"/> = $driver->escape($<xsl:value-of select="@name"/>);
                </xsl:for-each>
                $spCall = "CALL <xsl:value-of select="@databaseName"/>("
                <xsl:for-each select="parameter">
                    . "'$<xsl:value-of select="@name"/>'"
                </xsl:for-each>.")";

                <xsl:choose>
                    <xsl:when test="@resultType='single'">
                        return Util::getFromIndex(self::executeStoredProcedure($spCall), 0);
                    </xsl:when>
                    <xsl:when test="@resultType='list'">
                        return self::executeStoredProcedure($spCall);
                    </xsl:when>
                    <xsl:when test="@resultType='resultset'">
                        return $driver->executeStoredProcedure($spCall);
                    </xsl:when>
                </xsl:choose>
            }
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="executeStoredProcedure">
        /**
         * @param string $invocation
         * @return <xsl:value-of select="/entity/@constructClass"/>[]
         */
        private static function executeStoredProcedure($invocation) {
            $driver = ServiceLocator::getDriver();
            $objectList = array();
            $resultSet = $driver->executeStoredProcedure($invocation);
            while ($resultSet->hasNext()) {
                $objectList[] =  self::createInstanceFromResultSet($resultSet);
            }
            $resultSet->close();
            return $objectList;
        }
    </xsl:template>


    <xsl:template name="createInstanceFromResultSet">
        /**
         * @param ResultSet $res
         * @return <xsl:value-of select="/entity/@constructClass"/>
         */
        public static function createInstanceFromResultSet(ResultSet $res) {
            $entity = new <xsl:value-of select="/entity/@constructClass"/>();
            $entity->initializeFromResultSet($res);
            return $entity;
        }
    </xsl:template>

    <xsl:template name="batchSaver">
       /**
        * @param $objectList <xsl:value-of select="/entity/@constructClass"/>[]
        */
        public static function batchSave(array $objectList) {
            $batchCall = "";
            foreach($objectList as $object) {
                $batchCall .= $object->createSaveStoredProcedureCall();
            }
            $driver = ServiceLocator::getDriver();
            $driver->multiQuery($batchCall);
        }
    </xsl:template>



    <xsl:template name="attributes">

            /**
             * holds bool if this entity is existing in the database
             * @var bool
             */
            protected $_existing;
        <xsl:for-each select="/entity/attributeList/attribute">
            /**
             * @var <xsl:value-of select="@type"/>
             */
            protected $<xsl:value-of select="@name"/>;
        </xsl:for-each>
        
        <xsl:for-each select="/entity/referenceList/reference">
           /**
            * @var <xsl:value-of select="@foreignConstructClass"/>
            */
            protected $<xsl:value-of select="@name"/>Obj;

            <xsl:variable name="referenceName" select="@name"/>
            <xsl:for-each select="columnList/column">
            /**
             * @var <xsl:value-of select="@type"/>
             */
             protected $<xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>;
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="/entity/collectorList/collector">
            /**
             * @var <xsl:value-of select="@foreignConstructClass"/>[]
             */
            protected $<xsl:value-of select="@name"/>;
        </xsl:for-each>

    </xsl:template>


    <xsl:template name="constructor">
        /**
         * constructs a new instance of <xsl:value-of select="/entity/@name"/>
         */
        public function __construct() {
            $this->_existing = false;

            <!-- iterate attributes -->
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:if test="@defaultValue != ''">
                    $this-><xsl:value-of select="@name"/> = <xsl:value-of select="@defaultValue"/>;
                </xsl:if>
            </xsl:for-each>

            <!-- iterate references -->
            <xsl:for-each select="/entity/referenceList/reference">
                $this-><xsl:value-of select="@name"/>Obj = null;
                <xsl:variable name="referenceName" select="@name"/>
                <xsl:for-each select="columnList/column">
                    $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = null;
                </xsl:for-each>
            </xsl:for-each>

            <xsl:for-each select="/entity/collectorList/collector">
                $this-><xsl:value-of select="@name"/> = null;
            </xsl:for-each>
        }
    </xsl:template>


    <xsl:template name="save">
        /**
         *
         */
        protected function createSaveStoredProcedureCall() {
            <!-- make sure ids are given -->
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:if test="@primaryKey = 'true'">
                    $this->get<xsl:value-of select="@methodName"/>(true);
                </xsl:if>
            </xsl:for-each>
            <!-- Build stored procedure call with all parameters -->
            $driver = ServiceLocator::getDriver();
            $spCall = ($this->_existing) ? "CALL <xsl:value-of select="/entity/standardStoredProcedures/@update"/> " : "CALL <xsl:value-of select="/entity/standardStoredProcedures/@insert"/> ";
            $spCall .= "("

            <!-- iterate references -->
            <xsl:for-each select="/entity/referenceList/reference">
                <xsl:if test="position() != 1">
                    . ","
                </xsl:if>
                <xsl:variable name="referenceName" select="@name"/>
                <!-- iterate column list -->
                <xsl:for-each select="columnList/column">
                    <xsl:choose>
                        <xsl:when test="@type = 'bool' or @type = 'int' or @type='float'">
                            . Util::quoteNumber($this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>)
                        </xsl:when>
                        <xsl:when test="@type = 'string'">
                            . Util::quoteEscape($driver, $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>)
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test="position() != last()">."," </xsl:if>
                </xsl:for-each>
            </xsl:for-each>

            <!-- iterate attributes -->
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:if test="(position() = 1) and (/entity/@hasReferences = 'true')">
                    . ","
                </xsl:if>
                <xsl:if test="position() != 1">
                    . ","
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@type = 'bool' or @type = 'int' or @type = 'float'">
                        . Util::quoteNumber($this-><xsl:value-of select="@name"/>)
                    </xsl:when>
                    <xsl:when test="@type = 'string'">
                        . Util::quoteEscape($driver, $this-><xsl:value-of select="@name"/>)
                    </xsl:when>
                    <xsl:when test="@type = 'DateTime'">
                        <xsl:choose>
                            <xsl:when test="@dbType = 'DATETIME'">
                                . Util::quoteDateTime($this-><xsl:value-of select="@name"/>)
                            </xsl:when>
                            <xsl:when test="@dbType='DATE'">
                                . Util::quoteDate($this-><xsl:value-of select="@name"/>)
                            </xsl:when>
                            <xsl:when test="@dbType='TIME'">
                                . Util::quoteTime($this-><xsl:value-of select="@name"/>)
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>. ");";
            return $spCall;
        }

        /**
         * @param bool $cascade
         * @param Passport $passport
         */
        public function save($cascade = false, $passport=null) {

            <!-- make sure ids are given -->
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:if test="@primaryKey = 'true'">
                    $this->get<xsl:value-of select="@methodName"/>(true);
                </xsl:if>
            </xsl:for-each>

            if (!$passport) {
                $passport = new Passport();
            }

            if (!$passport->furtherTravelAllowed('<xsl:value-of select="/entity/@table"/>',$this)) {
                return;
            }

            <!-- Build stored procedure call with all parameters -->
            $driver = ServiceLocator::getDriver();
            $spCall = $this->createSaveStoredProcedureCall();

            $driver->execute($spCall);
            $this->_existing = true;

            if (!$cascade) {
                return;
            }

            <xsl:for-each select="/entity/referenceList/reference">
                if ($this-><xsl:value-of select="@name"/>Obj !== null) {
                    $this-><xsl:value-of select="@name"/>Obj->save($cascade, $passport);

                }
            </xsl:for-each>

            <xsl:for-each select="/entity/collectorList/collector">
                if ($this-><xsl:value-of select="@name"/> !== null) {
                    foreach($this-><xsl:value-of select="@name"/> as $c) {
                        $c->save($cascade, $passport);
                    }
                }
            </xsl:for-each>

        }
    </xsl:template>

    <xsl:template name="arePrimaryKeyIdentical">
        /**
         * @param <xsl:value-of select="/entity/@constructClass"/> $other
         * @return bool
         */
        public function arePrimaryKeyIdentical($other) {
            return
            <xsl:for-each select="/entity/attributeList/attribute[@primaryKey = 'true']">
                $this->get<xsl:value-of select="@methodName"/>() === $other->get<xsl:value-of select="@methodName"/>()
                <xsl:if test="position() != last()"> and </xsl:if>
            </xsl:for-each>;
        }
    </xsl:template>


    <xsl:template name="validate">
        /**
         * @return bool
         */
        public function validate() {
            $isValid = true;
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:choose>
                    <xsl:when test="@type = 'bool' or @type='int' or @type='float'">
                        $isValid &amp;= Util::setType($this-><xsl:value-of select="@name"/>, "<xsl:value-of select="@type"/>");
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="/entity/referenceList/reference">
                <xsl:variable name="referenceName" select="@name"/>
                <!-- iterate column list -->
                <xsl:for-each select="columnList/column">
                    <xsl:choose>
                        <xsl:when test="@type = 'bool' or @type='int' or @type='float'">
                            $isValid &amp;= Util::setType( $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>, "<xsl:value-of select="@type"/>");
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>

            return ($isValid === 1);
        }
    </xsl:template>


    <xsl:template name="fromResultSet">
       /**
        * @param ResultSet $res
        */
        public function initializeFromResultSet(ResultSet $res) {
            $this->_existing = true;
        <xsl:for-each select="/entity/attributeList/attribute">
            <xsl:choose>
                <xsl:when test="@type='bool'">
                    $this-><xsl:value-of select="@name"/> = $res->getBooleanValue('<xsl:value-of select="@dbName"/>');
                </xsl:when>
                <xsl:when test="@type='int'">
                    $this-><xsl:value-of select="@name"/> = $res->getIntegerValue('<xsl:value-of select="@dbName"/>');
                </xsl:when>
                <xsl:when test="@type='float'">
                    $this-><xsl:value-of select="@name"/> = $res->getFloatValue('<xsl:value-of select="@dbName"/>');
                </xsl:when>
                <xsl:when test="@type='string'">
                    $this-><xsl:value-of select="@name"/> = $res->getStringValue('<xsl:value-of select="@dbName"/>');
                </xsl:when>
                <xsl:when test="@type='DateTime'">
                    $this-><xsl:value-of select="@name"/> = $res->getDateTime('<xsl:value-of select="@dbName"/>');
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="/entity/referenceList/reference">
            <xsl:variable name="referenceName" select="@name"/>
            <!-- iterate column list -->
            <xsl:for-each select="columnList/column">
                <xsl:choose>
                    <xsl:when test="@type = 'bool'">
                        $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $res->getBooleanValue('<xsl:value-of select="@databaseName"/>');
                    </xsl:when>
                    <xsl:when test="@type ='int'">
                        $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $res->getIntegerValue('<xsl:value-of select="@databaseName"/>');
                    </xsl:when>
                    <xsl:when test="@type ='string'">
                        $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $res->getStringValue('<xsl:value-of select="@databaseName"/>');
                    </xsl:when>
                    <xsl:when test="@type ='DateTime'">
                        $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $res->getDateTime('<xsl:value-of select="@databaseName"/>');
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
        }
    </xsl:template>


    <xsl:template name="fromHttpRequest">
        /**
        * @param HttpRequest $req
        */
        public function initializeFromHttpRequest(HttpRequest $req) {
        $this->_existing = $req->getBooleanValue("_existing");
        <xsl:for-each select="/entity/attributeList/attribute">
            <xsl:choose>
                <xsl:when test="@type='bool'">
                    $this-><xsl:value-of select="@name"/> = $req->getBooleanValue('<xsl:value-of select="@name"/>');
                </xsl:when>
                <xsl:when test="@type='int'">
                    $this-><xsl:value-of select="@name"/> = $req->getIntegerValue('<xsl:value-of select="@name"/>');
                </xsl:when>
                <xsl:when test="@type='float'">
                    $this-><xsl:value-of select="@name"/> = $req->getFloatValue('<xsl:value-of select="@name"/>');
                </xsl:when>
                <xsl:when test="@type='string'">
                    $this-><xsl:value-of select="@name"/> = $req->getStringValue('<xsl:value-of select="@name"/>', <xsl:value-of select="@length"/>);
                </xsl:when>
                <xsl:when test="@type='DateTime'">
                    $this-><xsl:value-of select="@name"/> = $req->getDateTime('<xsl:value-of select="@name"/>');
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="/entity/referenceList/reference">
            <xsl:choose>
                <xsl:when test="@foreignKeyType ='int'">
                    $this-><xsl:value-of select="@name"/>Id = $req->getIntegerValue('<xsl:value-of select="@name"/>');
                </xsl:when>
                <xsl:when test="@foreignKeyType ='string'">
                    $this-><xsl:value-of select="@name"/>Id = $req->getStringValue('<xsl:value-of select="@name"/>');
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        }
    </xsl:template>


    <xsl:template name="fromArray">
        /**
         * @param string $jsonString
         */
        public function fromJSON($jsonString) {
            $this->fromArray(json_decode($jsonString, true));
        }

        /**
         * @param array $data
         */
        public function fromArray(array $data) {
            $arrayAccessor = new ArrayAccessor($data);
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:choose>
                    <xsl:when test="@type='bool'">
                        $this-><xsl:value-of select="@name"/> = $arrayAccessor->getBooleanValue('<xsl:value-of select="@name"/>');
                    </xsl:when>
                    <xsl:when test="@type='int'">
                        $this-><xsl:value-of select="@name"/> = $arrayAccessor->getIntegerValue('<xsl:value-of select="@name"/>');
                    </xsl:when>
                    <xsl:when test="@type='float'">
                        $this-><xsl:value-of select="@name"/> = $arrayAccessor->getFloatValue('<xsl:value-of select="@name"/>');
                    </xsl:when>
                    <xsl:when test="@type='string'">
                        $this-><xsl:value-of select="@name"/> = $arrayAccessor->getStringValue('<xsl:value-of select="@name"/>', <xsl:value-of select="@length"/>);
                    </xsl:when>
                    <xsl:when test="@type='DateTime'">
                        $this-><xsl:value-of select="@name"/> = $arrayAccessor->getDateTime('<xsl:value-of select="@name"/>');
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>

        <xsl:for-each select="/entity/referenceList/reference">
            $<xsl:value-of select="@name"/>Data = $arrayAccessor->get('<xsl:value-of select="@name"/>');
            if ($<xsl:value-of select="@name"/>Data) {
            $this-><xsl:value-of select="@name"/>Obj = new <xsl:value-of select="@foreignConstructClass"/>();
            $this-><xsl:value-of select="@name"/>Obj->fromArray($<xsl:value-of select="@name"/>Data);
            } else {
            <xsl:variable name="referenceName" select="@name"/>
            <xsl:for-each select="columnList/column">
                $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $arrayAccessor->get('<xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>');
            </xsl:for-each>
            }
        </xsl:for-each>

        <xsl:for-each select="/entity/collectorList/collector">
            $<xsl:value-of select="@name"/>DataList = $arrayAccessor->getArray('<xsl:value-of select="@name"/>');
            if ($<xsl:value-of select="@name"/>DataList) {
                $this-><xsl:value-of select="@name"/> = array();
                foreach ($<xsl:value-of select="@name"/>DataList as $<xsl:value-of select="@name"/>Data) {
                    $obj = new <xsl:value-of select="@foreignConstructClass"/>();
                    $obj->fromArray($<xsl:value-of select="@name"/>Data);
                    $this-><xsl:value-of select="@name"/>[] = $obj;
                }
            }
        </xsl:for-each>

        }
    </xsl:template>


    <xsl:template name="toArray">

        /**
         * @return string
         */
        public function toJSON() {
            return json_encode($this->toArray());
        }

        /**
          * @param Passport $passport
          *
          * @return array|void
          */
        public function toArray($passport = null) {
            if (!$passport) {
                $passport = new Passport();
            }

            if (!$passport->furtherTravelAllowed('<xsl:value-of select="/entity/@table"/>',$this)) {
                return null;
            }

            $result = array(
            <xsl:for-each select="/entity/attributeList/attribute">
                <xsl:choose>
                    <xsl:when test="@type='bool'">
                        "<xsl:value-of select="@name"/>" => $this-><xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:when test="@type='int'">
                        "<xsl:value-of select="@name"/>" => $this-><xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:when test="@type='float'">
                        "<xsl:value-of select="@name"/>" => $this-><xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:when test="@type='string'">
                        "<xsl:value-of select="@name"/>" => $this-><xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:when test="@type='DateTime'">
                        "<xsl:value-of select="@name"/>" => $this-><xsl:value-of select="@name"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>);

            <xsl:for-each select="/entity/referenceList/reference">
                if ($this-><xsl:value-of select="@name"/>Obj) {
                    $result["<xsl:value-of select="@name"/>"] = $this-><xsl:value-of select="@name"/>Obj->toArray($passport);
                }

                <xsl:variable name="referenceName" select="@name"/>
                <xsl:for-each select="columnList/column">
                    $result["<xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>"] = $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>;
                </xsl:for-each>
            </xsl:for-each>

            <xsl:for-each select="/entity/collectorList/collector">
                $result["<xsl:value-of select="@name"/>"] = array();
                if ($this-><xsl:value-of select="@name"/>) {
                    foreach($this-><xsl:value-of select="@name"/> as $<xsl:value-of select="@name"/>) {
                        $result["<xsl:value-of select="@name"/>"][] = $<xsl:value-of select="@name"/>->toArray($passport);
                    }
                }
            </xsl:for-each>

            return $result;
        }
    </xsl:template>


    <xsl:template name="linkRelations">

    /**
     * @param Passport $passport
     **/
    public function linkRelations($passport = null) {
        if (!$passport) {
            $passport = new Passport();
        }

        if (!$passport->furtherTravelAllowed('<xsl:value-of select="/entity/@table"/>',$this)) {
            return;
        }

        <xsl:for-each select="/entity/referenceList/reference">
            <!-- stores reference name for inner iteration -->
            <xsl:variable name="referenceName" select="@name"/>

            if ($this-><xsl:value-of select="@name"/>Obj) {
                $this->set<xsl:value-of select="@methodName"/>($this-><xsl:value-of select="@name"/>Obj);
                $this-><xsl:value-of select="@name"/>Obj->linkRelations($passport);
            }
        </xsl:for-each>

        <xsl:for-each select="/entity/collectorList/collector">
            if ($this-><xsl:value-of select="@name"/>) {
                foreach($this-><xsl:value-of select="@name"/> as $<xsl:value-of select="@name"/>) {
                    $<xsl:value-of select="@name"/>->set<xsl:value-of select="@referenceMethodName"/>($this);
                    $<xsl:value-of select="@name"/>->linkRelations($passport);
                }
            }
        </xsl:for-each>


    }

    </xsl:template>

    <xsl:template name="attributeGetterSetter">
        <xsl:for-each select="/entity/attributeList/attribute">
            /**
             * @param <xsl:if test="@primaryKey = 'true'">bool $generateKey</xsl:if>
             * @return <xsl:value-of select="@type"/>
             */
            public function get<xsl:value-of select="@methodName"/>(<xsl:if test="@primaryKey = 'true'">$generateKey=false</xsl:if>) {
                <xsl:if test="@primaryKey = 'true' and @autoValue != ''">
                    if ($generateKey and !$this-><xsl:value-of select="@name"/>) {
                    <xsl:choose>
                        <xsl:when test="@autoValue='uuid'">
                            $this-><xsl:value-of select="@name"/> = ServiceLocator::getUUIDGenerator()->uuid();
                        </xsl:when>
                        <xsl:when test="@autoValue='autoincrement'">
                            $this-><xsl:value-of select="@name"/> = ServiceLocator::getDriver()->getSequence("<xsl:value-of select="/entity/@table"/>");
                        </xsl:when>
                    </xsl:choose>
                    }
                </xsl:if>

                return $this-><xsl:value-of select="@name"/>;
            }

            /**
            * @param <xsl:value-of select="@type"/> $value
            */
            public function set<xsl:value-of select="@methodName"/>($value) {
                <xsl:choose>
                    <xsl:when test="@type='string'">$this-><xsl:value-of select="@name"/> = StringUtil::trimToNull($value, <xsl:value-of select="@length"/>);</xsl:when>
                    <xsl:otherwise>$this-><xsl:value-of select="@name"/> = $value;</xsl:otherwise>
                </xsl:choose>
            }
        </xsl:for-each>
    </xsl:template>



    <xsl:template name="referenceGetterSetter">
        <xsl:for-each select="/entity/referenceList/reference">
            <!-- stores reference name for inner iteration -->
            <xsl:variable name="referenceName" select="@name"/>
            <xsl:variable name="methodName" select="@methodName"/>
            /**
             * @param bool $forceReload
             * @return <xsl:value-of select="@foreignConstructClass"/>
             */
            public function get<xsl:value-of select="@methodName"/>($forceReload=false)
            {
                if ($this-><xsl:value-of select="@name"/>Obj === null or $forceReload) {
                    $this-><xsl:value-of select="@name"/>Obj = <xsl:value-of select="@foreignConstructClass"/>::getEntityByPrimaryKey(
                    <xsl:for-each select="columnList/column">
                        $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>);
                }
                <xsl:if test="@referenceCretorNeeded='true'">
                if ($this-><xsl:value-of select="@name"/>Obj !== null) {
                    $this-><xsl:value-of select="@name"/>Obj->set<xsl:value-of select="@foreignMethodName"/>($this,false);
                }
                </xsl:if>
                return $this-><xsl:value-of select="@name"/>Obj;
            }

            <xsl:for-each select="columnList/column">
                /**
                  * @return <xsl:value-of select="@type"/>
                  */
                public function get<xsl:value-of select="$methodName"/><xsl:value-of select="@methodName"/>(){
                    return $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/>;
                }
            </xsl:for-each>

            /**
             * @param <xsl:value-of select="@foreignConstructClass"/> $object
             * <xsl:if test="@referenceCretorNeeded='true'">@param bool $backlink</xsl:if>
             */
            public function set<xsl:value-of select="@methodName"/>($object<xsl:if test="@referenceCretorNeeded='true'">, $backlink=true</xsl:if>)
            {
                if ($object === null) {
                   $this-><xsl:value-of select="@name"/>Obj = null;
                    <xsl:for-each select="columnList/column">
                        $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = null;
                    </xsl:for-each>
                    return;
                }
                $this-><xsl:value-of select="@name"/>Obj = $object;
                <xsl:for-each select="columnList/column">
                    $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $object->get<xsl:value-of select="@methodName"/>(true);
                </xsl:for-each>

                <!-- for bidirectional relationships set-->
                <xsl:if test="@referenceCretorNeeded='true'">
                if ($backlink) {
                    $object->set<xsl:value-of select="@foreignMethodName"/>($this,false);
                }
                </xsl:if>
            }

            <xsl:for-each select="columnList/column">
                /**
                * @param <xsl:value-of select="@type"/> $id
                */
                public function set<xsl:value-of select="$methodName"/><xsl:value-of select="@methodName"/>($id)
                {
                    $this-><xsl:value-of select="$referenceName"/>_<xsl:value-of select="@name"/> = $id;
                    $this-><xsl:value-of select="$referenceName"/>Obj = null;
                }
            </xsl:for-each>

        </xsl:for-each>
    </xsl:template>


    <xsl:template name="collectorGetterSetter">
        <xsl:for-each select="/entity/collectorList/collector">

            /**
             * @param bool $forceReload
             * @return <xsl:value-of select="@foreignConstructClass"/>[]
             */
            public function get<xsl:value-of select="@methodName"/>($forceReload=false)
            {
                if ($this-><xsl:value-of select="@name"/> === null or $forceReload) {
                    $this-><xsl:value-of select="@name"/> = <xsl:value-of select="@foreignConstructClass"/>::getEntityBy<xsl:value-of select="@referenceMethodName"/>Reference(
                        <xsl:for-each select="/entity/attributeList/attribute[@primaryKey = 'true']">
                            $this->get<xsl:value-of select="@methodName"/>(true)<xsl:if test="position() != last()">,</xsl:if>
                        </xsl:for-each>);
                    foreach($this-><xsl:value-of select="@name"/> as $e) {
                        $e->set<xsl:value-of select="@referenceMethodName"/>($this);
                    }
                }
                return $this-><xsl:value-of select="@name"/>;
            }

            /**
             *
             */
            public function deleteAll<xsl:value-of select="@methodName"/>()
            {
                $this-><xsl:value-of select="@name"/> = null;
                <xsl:value-of select="@foreignConstructClass"/>::deleteEntityBy<xsl:value-of select="@referenceMethodName"/>Reference(
                    <xsl:for-each select="/entity/attributeList/attribute[@primaryKey = 'true']">
                        $this->get<xsl:value-of select="@methodName"/>(true)
                        <xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>
                );
            }

            /**
             * @param <xsl:value-of select="@foreignConstructClass"/> $object
             */
            public function addTo<xsl:value-of select="@methodName"/>(<xsl:value-of select="@foreignConstructClass"/> $object)
            {
                $object->set<xsl:value-of select="@referenceMethodName"/>($this);
                if ($this-><xsl:value-of select="@name"/> === null) {
                    $this-><xsl:value-of select="@name"/> = array();
                }
                $this-><xsl:value-of select="@name"/>[] = $object;
            }

        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>