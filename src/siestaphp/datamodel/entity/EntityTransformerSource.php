<?php
/**
 * Created by PhpStorm.
 * User: gregor
 * Date: 28.06.15
 * Time: 22:27
 */

namespace siestaphp\datamodel\entity;
use siestaphp\datamodel\attribute\AttributeTransformerSource;
use siestaphp\util\File;


/**
 * Interface EntityTransformerSource
 * @package siestaphp\datamodel
 */
interface EntityTransformerSource extends EntitySource {


    /**
     * @return bool
     */
    public function isDateTimeUsed();


    /**
     * @return string[]
     */
    public function getUsedFQClassNames();


    /**
     * @return AttributeTransformerSource;
     */
    public function getPrimaryKeyAttributeList();


    /**
     * @param $baseDir
     * @return File
     */
    public function getTargetEntityFile($baseDir);


    /**
     * @param $baseDir
     * @return File
     */
    public function getAbsoluteTargetPath($baseDir);

    /**
     * @return bool
     */
    public function hasReferences();

    /**
     * @return bool
     */
    public function hasAttributes();


    /**
     * @return string
     */
    public function getFindByPKSignature();


    /**
     * @return string
     */
    public function getSPCallSignature();

}