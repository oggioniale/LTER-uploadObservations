<?xml version="1.0" encoding="UTF-8"?>
  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:sos="http://www.opengis.net/sos/2.0" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:swes="http://www.opengis.net/swes/2.0" 
  xmlns:gml="http://www.opengis.net/gml/3.2" 
  xmlns:sams="http://www.opengis.net/samplingSpatial/2.0" 
  xmlns:sf="http://www.opengis.net/sampling/2.0"
  xsi:schemaLocation="http://www.opengis.net/sos/2.0 http://schemas.opengis.net/sos/2.0/sosGetFeatureOfInterest.xsd http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd http://www.opengis.net/samplingSpatial/2.0 http://schemas.opengis.net/samplingSpatial/2.0/spatialSamplingFeature.xsd http://www.opengis.net/sampling/2.0 http://schemas.opengis.net/sampling/2.0/samplingFeature.xsd"
  version="1.0">
    <!-- Created By: Alessandro Oggioni - CNR IREA in Milano - 2021-07-12T16:44:00Z -->
    <!-- Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/4.0 -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"
  media-type="text/xml"/>
    <xsl:output method="text" encoding="utf-8" />
    
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />
    
    <xsl:template match="/">
      <!-- Inizio output -->
      <xsl:text>identifier;name;long;lat;sampledFeature</xsl:text>
      <xsl:value-of select="$newline" />
      <xsl:for-each select="//sos:GetFeatureOfInterestResponse/sos:featureMember/sams:SF_SpatialSamplingFeature">
        <xsl:value-of select="gml:identifier" />
        <xsl:value-of select="$separator" />
        
        <xsl:value-of select="gml:name" />
        <xsl:value-of select="$separator" />
        
        <xsl:value-of select="substring-after(sams:shape/gml:Point/gml:pos,' ')" />
        <xsl:value-of select="$separator" />
        
        <xsl:value-of select="substring-before(sams:shape/gml:Point/gml:pos,' ')" />
        <xsl:value-of select="$separator" />
                
        <xsl:value-of select="sf:sampledFeature/@xlink:href" />
        
        <xsl:value-of select="$newline" />
      </xsl:for-each>
    </xsl:template>
  </xsl:stylesheet>