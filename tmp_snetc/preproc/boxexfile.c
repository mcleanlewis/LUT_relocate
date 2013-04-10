/*******************************************************************************
 *
 * $Id: boxexfile.c 2507 2009-08-05 12:02:11Z jju $
 *
 * Author: Kari Keinanen, VTT Technical Research Centre of Finland
 * -------
 *
 * Date:   15.02.2007
 * -----
 *
 *******************************************************************************/

#include "boxexfile.h"
#include <stdio.h>
#include "ctinfo.h"
#include "str.h"
#include "memory.h"

static FILE *srcFile = NULL;

static void writeGenerationInfo(const char *snetBase, const char *boxBase, const char *boxType)
{
  fprintf(srcFile, "/**\n");
  fprintf(srcFile, " * @file %s.%s\n", boxBase, boxType);
  fprintf(srcFile, " *\n");
  fprintf(srcFile, " * Source code of extracted box language.\n");
  fprintf(srcFile, " *\n");
  fprintf(srcFile, " * THIS FILE HAS BEEN GENERATED.\n");
  fprintf(srcFile, " * DO NOT EDIT THIS FILE.\n");
  fprintf(srcFile, " * EDIT THE ORIGINAL SNET-SOURCE FILE %s.snet INSTEAD!\n", snetBase);
  fprintf(srcFile, " *\n");
  fprintf(srcFile, " * ALL CHANGES MADE TO THIS FILE WILL BE OVERWRITTEN!\n");
  fprintf(srcFile, " *\n");
  fprintf(srcFile, "*/\n\n");
}

bool openFile(const char *snetBase, const char *boxBase, const char *boxType)
{
  char *fileName = STRcatn(3, boxBase, ".", boxType);

  if((srcFile = fopen(fileName, "w")) == NULL) {
    CTIerror(CTI_ERRNO_FILE_ACCESS_ERROR,
	     "Source file %s open failed\n", fileName);
    return FALSE;
  }

  writeGenerationInfo(snetBase, boxBase, boxType);

  MEMfree(fileName);

  return TRUE;
}

void closeFile()
{
  if(srcFile != NULL) {
    fclose(srcFile);
    srcFile = NULL;
  }
}

void writeFile(const char *data)
{
  fprintf(srcFile, "%s", data);
}