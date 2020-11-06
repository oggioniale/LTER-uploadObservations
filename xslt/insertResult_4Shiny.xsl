<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sos="http://www.opengis.net/sos/2.0" xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:sml="http://www.opengis.net/sensorml/2.0" xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:swe1="http://www.opengis.net/swe/1.0.1" xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="swe1">
    <!-- Created By: Alessandro Oggioni - CNR IREA in Milano - 2019-06-14T00:00:00Z -->
    <!-- Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/4.0 -->
    
    <xsl:param name="TEMPLATE_ID" />
    <xsl:param name="VALUES" />
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes" media-type="text/xml" />
    
    <xsl:template match="/">
        <sos:InsertResult
    xmlns:sos="http://www.opengis.net/sos/2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" service="SOS" version="2.0.0" xsi:schemaLocation="http://www.opengis.net/sos/2.0 http://schemas.opengis.net/sos/2.0/sos.xsd">
            <sos:template><xsl:value-of select="$TEMPLATE_ID"/></sos:template>
            <sos:resultValues><xsl:value-of select="$VALUES"/></sos:resultValues>
        </sos:InsertResult>
    </xsl:template>
    
</xsl:stylesheet>