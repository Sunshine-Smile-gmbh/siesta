<?php
declare(strict_types = 1);

namespace Siesta\GeneratorPlugin\Entity;

use Nitria\ClassGenerator;
use Siesta\GeneratorPlugin\BasePlugin;
use Siesta\Model\Attribute;
use Siesta\Model\Entity;
use Siesta\Model\PHPType;

/**
 * @author Gregor Müller
 */
class AttributeGetterSetterPlugin extends BasePlugin
{
    /**
     * @param Entity $entity
     *
     * @return string[]
     */
    public function getUseClassNameList(Entity $entity) : array
    {
        $useList = [];
        foreach ($entity->getAttributeList() as $attribute) {
            if ($attribute->getPhpType() === PHPType::STRING) {
                $useList[] = 'Siesta\Util\StringUtil';
            }
            if ($attribute->getAutoValue() !== null) {
                $useList[] = 'Siesta\Sequencer\SequencerFactory';
            }
        }
        return $useList;
    }

    /**
     * @return string[]
     */
    public function getDependantPluginList() : array
    {
        return [
            'Siesta\GeneratorPlugin\Entity\MemberPlugin',
            'Siesta\GeneratorPlugin\Entity\ConstantPlugin'
        ];
    }

    /**
     * @param Entity $entity
     * @param ClassGenerator $classGenerator
     */
    public function generate(Entity $entity, ClassGenerator $classGenerator)
    {
        $this->setup($entity, $classGenerator);

        foreach ($entity->getAttributeList() as $attribute) {

            if ($attribute->getIsPrimaryKey()) {
                $this->generatePrimaryKeyGetter($attribute);
            } else {
                $this->generateGetter($attribute);
            }

            $this->generateSetter($attribute);

            if ($attribute->getPhpType() === PHPType::ARRAY) {
                $this->generateAddToArrayType($attribute);
                $this->generateGetFromArrayType($attribute);
            }

        }
    }

    /**
     * @param Attribute $attribute
     */
    protected function generateGetter(Attribute $attribute)
    {
        $methodName = "get" . $attribute->getMethodName();
        $method = $this->classGenerator->addPublicMethod($methodName);
        $method->setReturnType($attribute->getFullyQualifiedTypeName());

        $method->addCodeLine('return $this->' . $attribute->getPhpName() . ';');
    }

    /**
     * @param Attribute $attribute
     */
    protected function generatePrimaryKeyGetter(Attribute $attribute)
    {
        $methodName = "get" . $attribute->getMethodName();
        $method = $this->classGenerator->addPublicMethod($methodName);
        $method->addParameter(PHPType::BOOL, 'generateKey', 'false');
        $method->addParameter(PHPType::STRING, 'connectionName', 'null');
        $method->setReturnType($attribute->getPhpType(), true);

        $autoValue = $attribute->getAutoValue();

        $memberName = '$this->' . $attribute->getPhpName();

        $method->addIfStart('$generateKey && ' . $memberName . ' === null');
        $method->addCodeLine($memberName . ' = SequencerFactory::nextSequence("' . $autoValue . '", self::TABLE_NAME, $connectionName);');
        $method->addIfEnd();

        $method->addCodeLine('return ' . $memberName . ';');
    }

    /**
     * @param Attribute $attribute
     */
    protected function generateSetter(Attribute $attribute)
    {
        $name = $attribute->getPhpName();
        $type = $attribute->getPhpType();
        $methodName = "set" . $attribute->getMethodName();

        $method = $this->classGenerator->addPublicMethod($methodName);
        $method->addParameter($attribute->getFullyQualifiedTypeName(), $name, 'null');

        if ($type === PHPType::STRING) {

            $length = $attribute->getLength() !== null ? $attribute->getLength() : 'null';
            $method->addCodeLine('$this->' . $name . ' = StringUtil::trimToNull($' . $name . ", " . $length . ");");
        } else {
            $method->addCodeLine('$this->' . $name . ' = $' . $name . ";");
        }
    }

    /**
     * @param Attribute $attribute
     */
    protected function generateAddToArrayType(Attribute $attribute)
    {
        $methodName = "addTo" . $attribute->getMethodName();
        $method = $this->classGenerator->addPublicMethod($methodName);
        $method->addParameter(PHPType::STRING, "key");
        $method->addParameter(null, "value", 'null');

        $memberName = '$this->' . $attribute->getPhpName();

        $method->addIfStart($memberName . ' === null');
        $method->addCodeLine($memberName . ' = [];');
        $method->addIfEnd();

        $method->addCodeLine($memberName . '[$key] = $value;');
    }

    protected function generateGetFromArrayType(Attribute $attribute)
    {
        $methodName = "getFrom" . $attribute->getMethodName();
        $method = $this->classGenerator->addPublicMethod($methodName);
        $method->addParameter(PHPType::STRING, "key");
        $method->setReturnType(null, true);
        $memberName = '$this->' . $attribute->getPhpName();

        $method->addCodeLine('return ArrayUtil::getFromArray(' . $memberName . ', $key);');

    }

}