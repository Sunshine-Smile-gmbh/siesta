<?php
declare(strict_types = 1);

namespace Siesta\Validator;

use Siesta\Contract\DataModelValidator;
use Siesta\Model\DataModel;
use Siesta\Model\ValidationLogger;
use Siesta\Util\ArrayUtil;

/**
 * @author Gregor Müller
 */
class DefaultDataModelValidator implements DataModelValidator
{
    const ERROR_DUPLICATE_TABLE_NAME = "Table '%s' is used more than once.";

    const ERROR_DUPLICATE_TABLE_NAME_CODE = 1000;

    const ERROR_DUPLICATE_CLASS_NAME = "Class '%s' is used more than once.";

    const ERROR_DUPLICATE_CLASS_NAME_CODE = 1001;

    /**
     * @var DataModel
     */
    protected $dataModel;

    /**
     * @var ValidationLogger
     */
    protected $logger;

    /**
     * @param DataModel $dataModel
     * @param ValidationLogger $logger
     */
    public function validate(DataModel $dataModel, ValidationLogger $logger)
    {
        $this->dataModel = $dataModel;
        $this->logger = $logger;
        $this->validateTableNamesUnique();
        $this->validateClassNamesUnique();
    }

    /**
     * @param string $text
     * @param int $code
     */
    protected function error(string $text, int $code)
    {
        $this->logger->error($text, $code);
    }

    /**
     *
     */
    protected function validateTableNamesUnique()
    {
        $nameList = [];
        $duplicateNameList = [];
        foreach ($this->dataModel->getEntityList() as $entity) {
            $this->checkDuplicate($nameList, $duplicateNameList, $entity->getTableName());
        }

        foreach ($duplicateNameList as $duplicateName) {
            $error = sprintf(self::ERROR_DUPLICATE_TABLE_NAME, $duplicateName);
            $this->error($error, self::ERROR_DUPLICATE_TABLE_NAME_CODE);
        }
    }

    /**
     *
     */
    protected function validateClassNamesUnique()
    {
        $nameList = [];
        $duplicateNameList = [];
        foreach ($this->dataModel->getEntityList() as $entity) {
            $this->checkDuplicate($nameList, $duplicateNameList, $entity->getClassName());
        }

        foreach ($duplicateNameList as $duplicateName) {
            $error = sprintf(self::ERROR_DUPLICATE_CLASS_NAME, $duplicateName);
            $this->error($error, self::ERROR_DUPLICATE_CLASS_NAME_CODE);
        }
    }

    /**
     * @param array $nameList
     * @param array $duplicateNameList
     * @param $name
     */
    protected function checkDuplicate(array &$nameList, array &$duplicateNameList, $name)
    {
        $existing = ArrayUtil::getFromArray($nameList, $name);
        if ($existing) {
            $duplicateNameList[] = $name;
        }
        $nameList[$name] = true;
    }
}