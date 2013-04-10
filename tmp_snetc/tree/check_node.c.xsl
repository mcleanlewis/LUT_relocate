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

<!--  $Id: check_node.c.xsl 1723 2007-11-12 15:09:56Z cg $  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="1.0">

<xsl:import href="../xml/common_key_tables.xsl"/>
<xsl:import href="../xml/common_travfun.xsl"/>
<xsl:import href="../xml/common_node_access.xsl"/>
<xsl:import href="../xml/common_name_to_nodeenum.xsl"/>

<xsl:output method="text" indent="no"/>
<xsl:strip-space elements="*"/>

<!-- 
     This stylesheet generates a check_node.c file implementing all
     functions needed to touch a specific node

     templates:

     traversals:

     main generates the complete file. see templates for details.
-->
<!--
     traversal main /

     The output is generated using the following layout:

     - doxygen file header
     - doxugen file group tag
     - includes
     - call to subtemplates to generate the functions itself
     - doxygen file group end tag

-->
<xsl:template match="/">
  <!-- generate file header and doxygen group -->
  <xsl:call-template name="travfun-file">
    <xsl:with-param name="file">
      <xsl:value-of select="'check_node.c'"/>
    </xsl:with-param>
    <xsl:with-param name="desc">
      <xsl:value-of select="'Functions needed by chkm traversal.'"/>
    </xsl:with-param>
    <xsl:with-param name="xslt">
      <xsl:value-of select="'$Id: check_node.c.xsl 1723 2007-11-12 15:09:56Z cg $'"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="travfun-group-begin">
    <xsl:with-param name="group">
      <xsl:value-of select="'check'"/>
    </xsl:with-param>
    <xsl:with-param name="name">
      <xsl:value-of select="'Touch all Tree Functions to catch every'" />
      <xsl:value-of select="' node, son and attribute'"/>
    </xsl:with-param>
    <xsl:with-param name="desc">
      <xsl:value-of select="'Functions needed by free traversal.'"/>
    </xsl:with-param>
  </xsl:call-template>
  <!-- includes -->
  <xsl:text>

#include "check_node.h"
#include "check_attribs.h"
#include "tree_basic.h"
#include "traverse.h"
#include "dbug.h"
#include "check_mem.h"

#define CHKMTRAV( node, info) (node != NULL) ? TRAVdo( node, info) : node
#define CHKMCOND( node, info)                                    \
    ? CHKMTRAV( node, info)                                      \
    : (node)



/*******************************************************************************
 *
 * @fn CHKMpostfun
 *
 * This is the postfun function of the CHKM Traversal  
 *
 ******************************************************************************/
node *CHKMpostfun( node * arg_node, info * arg_info)
{
DBUG_ENTER( "CHKMpostfun");

CHKMappendErrorNodes( arg_node, arg_info);

DBUG_RETURN( arg_node);
}
  </xsl:text>
  <!-- functions -->
  <xsl:apply-templates select="//syntaxtree/node">
    <xsl:sort select="@name"/>
  </xsl:apply-templates>
  <!-- end of doxygen group -->
  <xsl:call-template name="travfun-group-end"/>
</xsl:template>


<!--
     traversal main node

     generates a generic touch function for any node

     layout of output:

     - function head and comment
       - call templates for @name
     - function body
       - call templates for sons
       - call templates for attributes
     
     remarks:

     the body contains calls to touch for all nodes and attributes.
     For each attribute a unique touch function is called. This function
     has to decide whether to touch an attribute or not. This includes
     a test for non-null if the attribute is a pointer type!
     Attribute arrays are iterated by this function, thus the touch
     function for array attributes has to touch one element only!

     The return value is the arg_node, who was called in the function call.
-->

<xsl:template match="node">
  <!-- generate head and comment -->
  <xsl:apply-templates select="@name"/>
  <!-- start of body -->
  <xsl:value-of select="'{'"/>
  <!-- if there is a for loop for initialising attributes, we 
       need a variable cnt, which is created here -->
  <xsl:if test="attributes/attribute[key(&quot;arraytypes&quot;, ./type/@name)]">
    <xsl:value-of select="'int cnt;'" />
  </xsl:if>
  <!-- DBUG_ENTER statement -->
  <xsl:value-of select="'DBUG_ENTER( &quot;CHKM'"/>
  <xsl:call-template name="lowercase" >
    <xsl:with-param name="string" >
      <xsl:value-of select="@name"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="'&quot;);'"/>

  <!-- touch the arg_node -->
  <xsl:value-of select="'CHKMtouch( arg_node, arg_info);'"/>

  <!-- touch the son and the attributs structure -->
  <xsl:value-of select="'CHKMtouch( '"/>
  <xsl:value-of select="'arg_node->sons.'"/>
  <xsl:call-template name="name-to-nodeenum" >
    <xsl:with-param name="name" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="', arg_info);'"/>

  <xsl:value-of select="'CHKMtouch( '"/>
  <xsl:value-of select="'arg_node->attribs.'"/>
  <xsl:call-template name="name-to-nodeenum" >
    <xsl:with-param name="name" select="@name"/>
  </xsl:call-template>
  <xsl:value-of select="', arg_info);'"/>

  <!-- trav the node error -->
  <xsl:value-of select="'NODE_ERROR( arg_node) = CHKMTRAV( NODE_ERROR( arg_node), arg_info);'"/>

  <xsl:apply-templates select="sons/son[@name = &quot;Next&quot;]"/>
  <!-- call touch for attributes -->
  <xsl:apply-templates select="attributes/attribute"/>
  <!-- call touch for all other sons -->
  <xsl:apply-templates select="sons/son[not( @name= &quot;Next&quot;)]"/>

  <!-- DBUG_RETURN call -->
  <xsl:value-of select="'DBUG_RETURN( arg_node);'"/>
  <!-- end of body -->
  <xsl:value-of select="'}'"/>
</xsl:template>


<!--
     traversal main @name

     generates a comment and function head

     layout:
   
     - call travfun-comment template
     - call travfun-head template
-->

<xsl:template match="@name">
  <xsl:call-template name="travfun-comment">
    <xsl:with-param name="prefix">CHKM</xsl:with-param>
    <xsl:with-param name="name"><xsl:value-of select="." /></xsl:with-param>
    <xsl:with-param name="text">Touched the node and its sons/attributes</xsl:with-param>
  </xsl:call-template>  
  <xsl:call-template name="travfun-head">
    <xsl:with-param name="prefix">CHKM</xsl:with-param>
    <xsl:with-param name="name"><xsl:value-of select="." /></xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!--
     traversal main son

     calls the touch function for a specific son

     example:

     ARG_NEXT( arg_node) = CHKMTRAV( ARG_NEXT( arg_node), arg_info);

     remarks:
 
     for all sons, the macro CHKTRAV is called.x
-->
     
<xsl:template match="son">
  <xsl:call-template name="node-access">
    <xsl:with-param name="node">arg_node</xsl:with-param>
    <xsl:with-param name="nodetype">
      <xsl:value-of select="../../@name"/>
    </xsl:with-param>
    <xsl:with-param name="field">
      <xsl:value-of select="@name"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="' = CHKMTRAV( '" />
  <xsl:call-template name="node-access">
    <xsl:with-param name="node">arg_node</xsl:with-param>
    <xsl:with-param name="nodetype">
      <xsl:value-of select="../../@name"/>
    </xsl:with-param>
    <xsl:with-param name="field">
      <xsl:value-of select="@name"/>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:value-of select="' , arg_info);'"/>
</xsl:template>


<!--
     traversal main attribute

     calls the touch function for a specific attribute

     example:

     ASSIGN_NEXT (arg_node) = CHKMTRAV (ASSIGN_NEXT (arg_node), arg_info);
     for (cnt = 0; cnt < 7; cnt++)
     {
       ASSIGN_MASK (arg_node, cnt) = FreeMask (ASSIGN_MASK (arg_node, cnt));
     }

     remark:

     Array attributes are iterated by the generated code using a for loop.
     Touch functions for attributes are always called with one element!

-->
<xsl:template match="attribute">
  <xsl:choose>
    <!-- literal attributes are ignored -->
    <xsl:when test="key(&quot;types&quot;, ./type/@name)[@copy = &quot;literal&quot;]">
      <!-- do nothing -->
    </xsl:when>
    <xsl:otherwise>
      <!-- if it is an array, we have to build a for loop over its elements -->
      <xsl:if test="key(&quot;arraytypes&quot;, ./type/@name)">
        <xsl:value-of select="'for( cnt = 0; cnt &lt; '" />
        <xsl:value-of select="key(&quot;types&quot;, ./type/@name)/@size"/>
        <xsl:value-of select="'; cnt++) { '" />
      </xsl:if>
      <!-- left side of assignment -->
      <xsl:call-template name="node-access">
        <xsl:with-param name="node">
          <xsl:value-of select="'arg_node'" />
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
      <xsl:value-of select="'CHKMattrib'"/>
      <xsl:value-of select="./type/@name"/>
      <xsl:value-of select="'('"/>
      <xsl:call-template name="node-access">
        <xsl:with-param name="node">
          <xsl:value-of select="'arg_node'" />
        </xsl:with-param>
        <xsl:with-param name="nodetype">
          <xsl:value-of select="../../@name" />
        </xsl:with-param>
        <xsl:with-param name="field">
          <xsl:value-of select="@name" />
        </xsl:with-param>
        <xsl:with-param name="index">
          <xsl:if test="key(&quot;arraytypes&quot;, ./type/@name)">
            <xsl:value-of select="'cnt'"/>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="', arg_info);'"/>
      <!-- if it is an array, we have to complete the for loop -->
      <xsl:if test="key(&quot;arraytypes&quot;, ./type/@name)">
        <xsl:value-of select="'}'"/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:variable name="newline">
  <xsl:text>
  </xsl:text>
</xsl:variable>

</xsl:stylesheet>
