<?xml version="1.0"?>

<!--
 ***********************************************************************
 *                                                                     *
 *                      Copyright (c) 1994-2007                        *
 *         SAC Research Foundation (http://www.sac-home.org/)          *
 *                                                                     *
 *                        All Rights Reserved                          *
 *                                                                     *
 *   The copyright holder makes no warranty of any kind with respect   *
 *   to this product and explicitly disclaims any implied warranties   *
 *   of merchantability or fitness for any particular purpose.         *
 *                                                                     *
 ***********************************************************************
 -->

<!--  $Id: common_make_body.xsl 2973 2011-03-30 09:40:05Z dlp $  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="1.0">

<xsl:import href="../xml/common_c_code.xsl"/>
<xsl:import href="../xml/common_name_to_nodeenum.xsl"/>
<xsl:import href="../xml/common_node_access.xsl"/>
<xsl:import href="../xml/common_make_assertion.xsl"/>

<xsl:output method="text" indent="no"/>
<xsl:strip-space elements="*"/>

<!-- templates for generating the body of a make function -->
<xsl:template match="node" mode="make-body">
  <xsl:value-of select="'{'"/>
  <!-- declarate variables -->
  <xsl:value-of select="'node *this;'" />
  <xsl:value-of select="'int size;'" />
  <!-- counter for for-loops -->
  <xsl:if test="attributes/attribute/type[key( &quot;arraytypes&quot;, @name)]" >
    <xsl:value-of select="'int cnt;'" />
  </xsl:if>
  <!-- DBUG_ENTER call -->
  <xsl:value-of select="'DBUG_ENTER( &quot;TBmake'"/>
  <xsl:call-template name="uppercase" >
    <xsl:with-param name="string" >
      <xsl:value-of select="substring( @name, 1, 1)" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="lowercase" >
    <xsl:with-param name="string" >
      <xsl:value-of select="substring( @name, 2, 30)" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="'&quot;);'"/>
  <!-- allocate new node this -->
  <xsl:value-of select="'DBUG_PRINT( &quot;MAKE&quot;, (&quot;allocating node structure&quot;));'"/>
  <xsl:value-of select="'size = sizeof(node) + sizeof( struct SONS_N_'" />
  <xsl:call-template name="uppercase">
    <xsl:with-param name="string" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="') + sizeof( struct ATTRIBS_N_'" />
  <xsl:call-template name="uppercase">
    <xsl:with-param name="string" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="');'" />
  <!-- 
      Part for Memorycheck START 
   -->
  <xsl:call-template name="newline" />
  <xsl:value-of select="'#ifdef SHOW_MALLOC'"/>
  <xsl:text>
  </xsl:text>
  <xsl:value-of select="'this = (node *) MEMmallocAt( size, file, line);'" />
  <xsl:value-of select="'CHKMsetNodeType(this, N_'" />
  <xsl:call-template name="lowercase" >
    <xsl:with-param name="string" >
      <xsl:value-of select="@name" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="');'" />
  <xsl:text>
  </xsl:text>
  <xsl:value-of select="'#else '" />
  <xsl:call-template name="newline" />
  <xsl:value-of select="'this = (node *) MEMmalloc( size);'" />
  <xsl:call-template name="newline" />
  <xsl:value-of select="'#endif /* SHOW_MALLOC */'" />
  <xsl:call-template name="newline" />
  <!-- 
      Part for Memorycheck END 
   -->
  <!-- set sons and attribs pointer -->
  <xsl:value-of select="'this->sons.'"/>
  <xsl:call-template name="name-to-nodeenum" >
    <xsl:with-param name="name" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="' = (struct SONS_N_'" />
  <xsl:call-template name="uppercase">
    <xsl:with-param name="string" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="' *) ((char *) this + sizeof( node));'" />
  <xsl:value-of select="'this->attribs.'"/>
  <xsl:call-template name="name-to-nodeenum" >
    <xsl:with-param name="name" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="' = (struct ATTRIBS_N_'" />
  <xsl:call-template name="uppercase">
    <xsl:with-param name="string" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="' *) ((char *) this + sizeof( node) + sizeof( struct SONS_N_'" />
  <xsl:call-template name="uppercase">
    <xsl:with-param name="string" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="'));'" />
  <xsl:value-of select="'NODE_TYPE( this) = N_'" />
  <xsl:call-template name="lowercase" >
    <xsl:with-param name="string" >
      <xsl:value-of select="@name" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="';'" />

  <xsl:value-of select="'DBUG_PRINT( &quot;MAKE&quot;, (&quot;address: &quot;F_PTR, this));'"/>
  <!-- set node type -->
  <xsl:value-of select="'DBUG_PRINT( &quot;MAKE&quot;, (&quot;setting node type&quot;));'"/>
  <xsl:value-of select="'NODE_TYPE(this) = '" />
  <xsl:call-template name="name-to-nodeenum">
    <xsl:with-param name="name">
      <xsl:value-of select="@name" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="';'" />
  <!-- set location -->
  <xsl:value-of select="'DBUG_PRINT( &quot;MAKE&quot;, (&quot;setting location&quot;));'"/>
  <xsl:value-of select="'NODE_FILE( this) = global.nodefile;'" />
  <xsl:value-of select="'NODE_LINE( this) = global.nodeline;'" />
  <xsl:value-of select="'NODE_COL( this) = global.nodecol;'" />
  <xsl:value-of select="'NODE_ERROR( this) = NULL;'" />
  <xsl:value-of select="'NODE_ERRCODE( this) = NULL;'" />
  <!-- assign sons and attributes a value -->
  <xsl:apply-templates select="sons/son" mode="make-body"/>
  <xsl:apply-templates select="attributes/attribute" mode="make-body"/>
  <!-- init flags -->
  <xsl:apply-templates select="flags/flag" mode="make-body" />
  <!-- if DBUG enabled, check for valid arguments -->
  <xsl:call-template name="newline" />
  <xsl:value-of select="'#ifndef DBUG_OFF'" />
  <xsl:call-template name="newline" />
  <xsl:value-of select="'DBUG_PRINT( &quot;MAKE&quot;, (&quot;doing son target checks&quot;));'"/>
  <!-- generate warning messages -->
  <xsl:apply-templates select="sons/son[not( @default)]" mode="make-assertion-target">
    <xsl:with-param name="self"><xsl:value-of select="'this'"/></xsl:with-param>
  </xsl:apply-templates>
  <xsl:call-template name="newline" />
  <xsl:value-of select="'#endif /* DBUG_OFF */'" />
  <xsl:call-template name="newline" />
  <!-- DBUG_RETURN call -->
  <xsl:value-of select="'DBUG_RETURN( this);'"/>
  <xsl:value-of select="'}'"/>
</xsl:template>

<!-- generate the assignment for a son -->
<xsl:template match="sons/son" mode="make-body">
  <xsl:value-of select="'DBUG_PRINT( &quot;MAKE&quot;, (&quot;assigning son '"/>
  <xsl:value-of select="@name"/>
  <xsl:value-of select="' initial value: &quot;F_PTR, '"/>
  <xsl:choose>
    <xsl:when test="@default">
      <xsl:value-of select="@default" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@name" />
    </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="'));'"/>
  <xsl:call-template name="node-access">
    <xsl:with-param name="node">
      <xsl:value-of select="'this'" />
    </xsl:with-param>
    <xsl:with-param name="nodetype">
      <xsl:value-of select="../../@name" />
    </xsl:with-param>
    <xsl:with-param name="field">
      <xsl:value-of select="@name" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="' = '"/>
  <!-- check for default value -->
  <xsl:choose>
    <xsl:when test="@default">
      <xsl:value-of select="@default" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@name" />
    </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="';'"/>
  <!-- if the current son is an avis, add the backref -->
  <xsl:if test="&quot;Avis&quot; = @name">
    <xsl:value-of select="'if ( '" />
    <xsl:call-template name="node-access">
      <xsl:with-param name="node">
        <xsl:value-of select="'this'" />
      </xsl:with-param>
      <xsl:with-param name="nodetype">
        <xsl:value-of select="../../@name" />
      </xsl:with-param>
      <xsl:with-param name="field">
        <xsl:value-of select="'Avis'" />
      </xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="' != NULL) {'" />
    <xsl:call-template name="node-access">
      <xsl:with-param name="node">
        <xsl:call-template name="node-access">
          <xsl:with-param name="node">
            <xsl:value-of select="'this'" />
          </xsl:with-param>
          <xsl:with-param name="nodetype">
            <xsl:value-of select="../../@name" />
          </xsl:with-param>
          <xsl:with-param name="field">
            <xsl:value-of select="'Avis'" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="nodetype">
        <xsl:value-of select="'Avis'" />
      </xsl:with-param>
      <xsl:with-param name="field">
        <xsl:value-of select="'Decl'" />
      </xsl:with-param>
    </xsl:call-template>
    <xsl:value-of select="'= this; }'"/>
    <xsl:call-template name="newline" />
  </xsl:if>
</xsl:template>
 
<!-- generate the assignmnent for an attribute -->
<xsl:template match="attributes/attribute" mode="make-body">
  <!-- if it is an array, we have to build a for loop over its elements -->
  <xsl:if test="key(&quot;arraytypes&quot;, ./type/@name)">
    <xsl:value-of select="'for( cnt = 0; cnt &lt; '" />
    <xsl:value-of select="key(&quot;types&quot;, ./type/@name)/@size"/>
    <xsl:value-of select="'; cnt++) { '" />
  </xsl:if>
  <!-- left side of assignment -->
  <xsl:call-template name="node-access">
    <xsl:with-param name="node">
      <xsl:value-of select="'this'" />
    </xsl:with-param>
    <xsl:with-param name="nodetype">
      <xsl:value-of select="../../@name" />
    </xsl:with-param>
    <xsl:with-param name="field">
      <xsl:value-of select="@name" />
    </xsl:with-param>
    <!-- if its is an array, we have to add another parameter -->
    <xsl:with-param name="index">
      <xsl:if test="key(&quot;arraytypes&quot;, ./type/@name)">
        <xsl:value-of select="'cnt'"/>
      </xsl:if>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="' = '" />
  <!-- right side of assignment -->
  <xsl:apply-templates select="@name" mode="make-body" />
  <xsl:value-of select="';'"/>
  <!-- finally, end the for loop if it was an array -->
  <xsl:if test="key(&quot;arraytypes&quot;, ./type/@name)">
    <xsl:value-of select="'}'" />
  </xsl:if>
</xsl:template> 

<!-- a default value implies that this attribute is not 
     passed as an argument to the make function, thus the r-value
     of the assignment is its default -->
<xsl:template match="@name[../@default]" mode="make-body">
  <xsl:value-of select="../@default"/>
</xsl:template>

<!-- no default and beeing a permanent attribute implies that this 
     attribute is passed as an argument thus the r-value is the 
     argument -->
<xsl:template match="@name[not(../@default)][../type/targets/target/phases/all][../type/targets/target/@mandatory = &quot;yes&quot;]" mode="make-body">
  <xsl:value-of select="."/>
  <!-- if its an array, we have to add the selector -->
  <xsl:if test="key(&quot;arraytypes&quot;, ../type/@name)">
    <xsl:value-of select="'[x]'" />
  </xsl:if>
</xsl:template>

<!-- no default and beeing a temporary attribute implies using the
     init value for this attributes type -->
<xsl:template match="@name" mode="make-body">
  <xsl:value-of select="key(&quot;types&quot;, ../type/@name)/@init"/>
</xsl:template>

<xsl:template match="flag[@default]" mode="make-body">
  <xsl:call-template name="node-access">
    <xsl:with-param name="node">
      <xsl:value-of select="'this'" />
    </xsl:with-param>
    <xsl:with-param name="nodetype">
      <xsl:value-of select="../../@name" />
    </xsl:with-param>
    <xsl:with-param name="field">
      <xsl:value-of select="@name" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="' = '"/>
  <xsl:value-of select="@default" />
  <xsl:value-of select="' ;'" />
</xsl:template>

<xsl:template match="flag" mode="make-body">
  <xsl:call-template name="node-access">
    <xsl:with-param name="node">
      <xsl:value-of select="'this'" />
    </xsl:with-param>
    <xsl:with-param name="nodetype">
      <xsl:value-of select="../../@name" />
    </xsl:with-param>
    <xsl:with-param name="field">
      <xsl:value-of select="@name" />
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="' = FALSE;'"/>
</xsl:template>

</xsl:stylesheet>
