<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sos="http://www.opengis.net/sos/2.0" 
    xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:sml="http://www.opengis.net/sensorml/2.0" 
    xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:swe1="http://www.opengis.net/swe/1.0.1" 
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="swe1">
    <!-- Created By: Alessandro Oggioni - CNR IREA in Milano - 2019-06-26T00:00:00Z -->
    <!-- Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/4.0 -->
    
    <xsl:param name="OFFERING" />
    <xsl:param name="BEGIN_TIME" />
    <xsl:param name="END_TIME" />
    <xsl:param name="LAB_DATETIME" />
    <xsl:param name="PROCEDURE" />
    <xsl:param name="NUM_VALUE" />
    <xsl:param name="sweValues" />
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"
        media-type="text/xml" />
    
    <xsl:template match="/">
<sos:InsertObservation service="SOS" version="2.0.0"
    xmlns:sos="http://www.opengis.net/sos/2.0"
    xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:sml="http://www.opengis.net/sensorml/2.0" 
    xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:swe1="http://www.opengis.net/swe/1.0.1" 
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sos/2.0 http://schemas.opengis.net/sos/2.0/sos.xsd http://www.opengis.net/samplingSpatial/2.0 http://schemas.opengis.net/samplingSpatial/2.0/spatialSamplingFeature.xsd">
    <!-- optional -->
    <!-- 
    <swes:extension>
      <swe:Boolean definition="SplitDataArrayIntoObservations">
        <swe:value>true</swe:value>
      </swe:Boolean>
    </swes:extension>
    -->
    <!-- multiple offerings are possible -->
    <sos:offering>$OFFERING</sos:offering>
    <sos:observation>
        <om:OM_Observation gml:id="o1">
            <om:type xlink:href="http://www.opengis.net/def/observationType/OGC-OM/2.0/OM_SWEArrayObservation"/>
            <om:phenomenonTime>
                <gml:TimePeriod gml:id="phenomenonTime">
                    <gml:beginPosition><xsl:value-of select="$BEGIN_TIME" /></gml:beginPosition>
                    <gml:endPosition><xsl:value-of select="$END_TIME" /></gml:endPosition>
                </gml:TimePeriod>
            </om:phenomenonTime>
            <om:resultTime>
                <gml:TimeInstant gml:id="resultTime">
                    <gml:timePosition><xsl:value-of select="$LAB_DATETIME" /></gml:timePosition>
                </gml:TimeInstant>
            </om:resultTime>
            <om:procedure><xsl:attribute name="xlink:href"><xsl:value-of select="$PROCEDURE" /></xsl:attribute></om:procedure>
            <om:observedProperty><!--xsl:attribute name="xlink:href"><xsl:value-of select="$OBS_PPROPERTY" /></xsl:attribute--></om:observedProperty>
            <om:featureOfInterest>
                <sams:SF_SpatialSamplingFeature gml:id="PTF"> <!-- change with a short name of point, station, etc. -->
                    <gml:identifier codeSpace="">http://sp7.irea.cnr.it/featureOfInterest/PiattaformaAcquaAlta</gml:identifier> <!-- change with a URL/URI of point, station, etc. -->
                    <gml:name>PTF - Piattaforma Acqua Alta</gml:name> <!-- change with a long name of point, station, etc. -->
                    <sf:type xlink:href="http://www.opengis.net/def/samplingFeatureType/OGC-OM/2.0/SF_SamplingPoint"/>
                    <sf:sampledFeature xlink:href="http://www.marineregions.org/rest/getGazetteerRecordByMRGID.json/3314/"/> <!-- from Marine Regions, 3314 is a MRGID of "Adriatic Sea" term -->
                    <sams:shape>
                        <gml:Point gml:id="ptf"> <!-- can be different with sams:SF_SpatialSamplingFeature gml:id -->
                            <gml:pos srsName="http://www.opengis.net/def/crs/EPSG/0/4326">45.3138 12.5088</gml:pos> <!-- change it! -->
                        </gml:Point>
                    </sams:shape>
                </sams:SF_SpatialSamplingFeature>
            </om:featureOfInterest>
            <om:result xsi:type="swe:DataArrayPropertyType">
                <swe:DataArray>
                    <swe:elementCount>
                        <swe:Count>
                            <swe:value><xsl:value-of select="$NUM_VALUE" /></swe:value>
                        </swe:Count>
                    </swe:elementCount>
                    <swe:elementType name="defs">
                        <swe:DataRecord>
                            <swe:field name="phenomenonTime">
                                <swe:Time definition="http://www.opengis.net/def/property/OGC/0/PhenomenonTime">
                                    <swe:uom xlink:href="http://www.opengis.net/def/uom/ISO-8601/0/Gregorian"/>
                                </swe:Time>
                            </swe:field>
                             <!--xsl:for-each select="//om:result/swe:DataArray/swe:DataRecord/swe:field">
                              <xsl:when test=".">
                                <xsl:if test="swe:Quantity/@name!='phenomenonTime'">
                                  <swe:field>
                                    <xsl:attribute name="name">
                                      <xsl:value-of select="./@name" />
                                    </xsl:attribute>
                                    <swe:Quantity>
                                    <xsl:attribute name="definition">
                                      <xsl:value-of select="./swe:Quantity/@definition" />
                                    </xsl:attribute>
                                      <swe:uom />
                                      <xsl:attribute name="code" namespace="@code">
                                        <xsl:value-of select="./swe:Quantity/swe:uom/@code" />
                                      </xsl:attribute>
                                    </swe:Quantity>
                                  </swe:field>
                                </xsl:if>
                              </xsl:when>
                            </xsl:for-each-->
                        </swe:DataRecord>
                    </swe:elementType>
                    <swe:encoding>
                        <swe:TextEncoding tokenSeparator="#" blockSeparator="@"/>
                    </swe:encoding>
                    <swe:values>
                        <xsl:value-of select="$sweValues" />
                    </swe:values>
                </swe:DataArray>
            </om:result>
        </om:OM_Observation>
    </sos:observation>
</sos:InsertObservation>
    </xsl:template>
    
</xsl:stylesheet>