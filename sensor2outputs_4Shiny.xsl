<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sos="http://www.opengis.net/sos/2.0" xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:sml="http://www.opengis.net/sensorml/2.0" xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:swe1="http://www.opengis.net/swe/1.0.1" xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="swe1">
    <!-- Created By: Alessandro Oggioni & Paolo Tagliolato - CNR IREA in Milano - 2019-03-06T00:00:00Z -->
    <!-- Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/4.0 -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"
        media-type="text/xml"/>

    <xsl:output method="text" encoding="utf-8" />
    <xsl:variable name="separator" select="'&#59;'" />
    <xsl:variable name="newline" select="'&#10;'" />
    
    <xsl:template match="/">
        <!-- Inizio output -->
        <xsl:text>link;name;uom;definition;lon;lat</xsl:text>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="//sml:outputs/sml:OutputList/sml:output[position()]">
            <xsl:text>&lt;a href=&quot;</xsl:text><xsl:value-of select="swe:Quantity/@definition"/><xsl:text>&quot; target=&quot;_blank&quot;></xsl:text><xsl:value-of select="translate(@name, '_', ' ')" /><xsl:text>&lt;/a&gt; (</xsl:text><xsl:value-of select="swe:Quantity/swe:uom/@code" /><xsl:text>)</xsl:text>
            <xsl:value-of select="$separator" />
            <xsl:value-of select="@name"/>
            <xsl:value-of select="$separator" />
            <xsl:value-of select="swe:Quantity/swe:uom/@code" />
            <xsl:value-of select="$separator" />
            <xsl:value-of select="swe:Quantity/@definition"/>
            <xsl:value-of select="$separator" />
            <xsl:value-of select="//sml:position/swe:Vector/swe:coordinate[@name='easting']/swe:Quantity/swe:value"/>
            <xsl:value-of select="$separator" />
            <xsl:value-of select="//sml:position/swe:Vector/swe:coordinate[@name='northing']/swe:Quantity/swe:value"/>
            <xsl:value-of select="$newline" />
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
