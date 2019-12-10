<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sos="http://www.opengis.net/sos/2.0" xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:sml="http://www.opengis.net/sensorml/2.0" xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:swe1="http://www.opengis.net/swe/1.0.1" xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="swe1">
    <!-- Created By: Alessandro Oggioni - CNR IREA in Milano - 2019-06-26T00:00:00Z -->
    <!-- Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/4.0 -->
    
    <xsl:param name="BEGIN_TIME" />
    <xsl:param name="END_TIME" />
    <xsl:param name="LAB_DATETIME" />
    <xsl:param name="PROCEDURE" />
    <xsl:param name="OBS_PPROPERTY" />
    <xsl:param name="NUM_VALUE" />
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"
        media-type="text/xml" />
    
    <xsl:template match="/">
<sos:InsertObservation service="SOS" version="2.0.0"
    xmlns:sos="http://www.opengis.net/sos/2.0"
    xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:sml="http://www.opengis.net/sensorML/1.0.1"
    xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sos/2.0 http://schemas.opengis.net/sos/2.0/sos.xsd          http://www.opengis.net/samplingSpatial/2.0 http://schemas.opengis.net/samplingSpatial/2.0/spatialSamplingFeature.xsd">
    <!-- optional -->
    <!-- 
    <swes:extension><swe:Boolean definition="SplitDataArrayIntoObservations"><swe:value>true</swe:value></swe:Boolean></swes:extension>
    -->
    <!-- multiple offerings are possible -->
    <sos:offering>offering:http://sp7.irea.cnr.it/sensors/vesk.ve.ismar.cnr.it/procedure/Seabird/SBE37/noSerialNumberDeclared/20140223115413720_11525/observations</sos:offering>
    <sos:observation>
        <om:OM_Observation gml:id="o1">
            <om:type xlink:href="http://www.opengis.net/def/observationType/OGC-OM/2.0/OM_SWEArrayObservation"/>
            <om:phenomenonTime>
                <gml:TimePeriod gml:id="phenomenonTime">
                    <gml:beginPosition><xsl:value-of select="$BEGIN_TIME" /></gml:beginPosition> <!-- add begin of time period (date and hour) -->
                    <gml:endPosition><xsl:value-of select="$END_TIME" /></gml:endPosition> <!-- add end of time period (date and hour) -->
                </gml:TimePeriod>
            </om:phenomenonTime>
            <om:resultTime>
                <gml:TimeInstant gml:id="resultTime">
                    <gml:timePosition><xsl:value-of select="$LAB_DATETIME" /></gml:timePosition> <!-- can be different to the phenomenonTime, e.g. it's a time when the samples are analyze in laboratory -->
                </gml:TimeInstant>
            </om:resultTime>
            <om:procedure><xsl:attribute name="xlink:href"><xsl:value-of select="$PROCEDURE" /></xsl:attribute></om:procedure> <!-- change with phenomenon value -->
            <om:observedProperty><xsl:attribute name="xlink:href"><xsl:value-of select="$OBS_PPROPERTY" /></xsl:attribute></om:observedProperty> <!-- change with observedProperty value -->
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
                            <swe:value><xsl:value-of select="$NUM_VALUE" /></swe:value> <!-- number of observations into the array below -->
                        </swe:Count>
                    </swe:elementCount>
                    <swe:elementType name="defs">
                        <swe:DataRecord>
                            <swe:field name="phenomenonTime">
                                <swe:Time definition="http://www.opengis.net/def/property/OGC/0/PhenomenonTime">
                                    <swe:uom xlink:href="http://www.opengis.net/def/uom/ISO-8601/0/Gregorian"/>
                                </swe:Time>
                            </swe:field>
                            <swe:field name="Maximum_depth_below_surface_of_the_water_body">
                                <swe:Quantity definition="http://vocab.nerc.ac.uk/collection/P01/current/MAXWDIST/">
                                    <swe:uom code="m"/>
                                </swe:Quantity>
                            </swe:field>
                            <swe:field name="Temperature_of_the_water_column"> <!-- change this with another observerd property -->
                                <swe:Quantity definition="http://vocab.nerc.ac.uk/collection/P02/current/TEMP/">
                                    <swe:uom code="degC"/>
                                </swe:Quantity>
                            </swe:field>
                        </swe:DataRecord>
                    </swe:elementType>
                    <swe:encoding>
                        <swe:TextEncoding tokenSeparator="#" blockSeparator="@"/>
                    </swe:encoding>
                    <swe:values>
                        2008-01-31T09:25:00#1#13.04@2008-01-31T09:25:05#2#13.053@2008-01-31T09:25:10#3#13.084@2008-01-31T09:25:15#4#13.17@2008-01-31T09:25:20#5#13.27@2008-01-31T09:25:25#6#13.315@2008-01-31T09:25:30#7#13.38@2008-01-31T09:25:35#8#13.432@2008-01-31T09:25:40#9#13.497@2008-01-31T09:25:45#10#13.502@2008-01-31T09:25:50#11#13.518@2008-01-31T09:25:55#12#13.53@2008-01-31T09:26:00#13#13.543@2008-01-31T09:26:05#14#13.557@2008-01-31T09:26:10#15#13.56@2008-01-31T09:26:15#16#13.557@2008-01-31T09:26:20#17#13.555@2008-01-31T09:26:25#18#13.552@2008-01-31T09:26:30#19#13.55@2008-01-31T09:26:35#20#13.55@2008-01-31T09:26:40#21#13.55@2008-01-31T09:26:45#22#13.55@2008-01-31T09:26:50#23#13.55@2008-01-31T09:26:55#24#13.557@2008-01-31T09:27:00#25#13.565@2008-01-31T09:27:05#26#13.595@2008-01-31T09:27:10#27#13.604@2008-01-31T09:27:15#28#13.655@2008-01-31T09:27:20#29#13.703@2008-01-31T09:27:25#30#13.73@2008-01-31T09:27:30#31#13.76@2008-01-31T09:27:35#32#13.797@2008-01-31T09:27:40#33#13.817@2008-01-31T09:27:45#34#13.84@2008-01-31T09:27:50#35#13.84@2008-01-31T09:27:55#36#13.855@2008-01-31T09:28:00#37#13.86@2008-01-31T09:28:05#38#13.867@2008-01-31T09:28:10#39#13.867@2008-01-31T09:28:15#40#13.87@2008-01-31T09:28:20#41#13.878@2008-01-31T09:28:25#42#13.882@2008-01-31T09:28:30#43#13.888@2008-01-31T09:28:35#44#13.888@2008-01-31T09:28:40#45#13.898@2008-01-31T09:28:45#46#13.9@2008-01-31T09:28:50#47#13.903@2008-01-31T09:28:55#48#13.903@
                    </swe:values>
                </swe:DataArray>
            </om:result>
        </om:OM_Observation>
    </sos:observation>
</sos:InsertObservation>
    </xsl:template>
    
</xsl:stylesheet>