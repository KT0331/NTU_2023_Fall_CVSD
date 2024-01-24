set cdstop  = "/home/raid7_4/raid1_1/linux/innovus/INNOVUS17.11/"
set soc_bin_prefix = "tools/celtic tools/plato tools/dfII tools /tools/tlfUtil"
set soc_lib_prefix = "tools"
set cds_bin = ""
set cds_lib = ""

if (${?CDSDIR} == 1) then
   unsetenv CDSDIR
endif

if (${?CDS_INST_DIR} == 1) then
   unsetenv CDS_INST_DIR
endif

foreach bin_pre (${soc_bin_prefix})
   set cds_bin=(${cds_bin} ${cdstop}/{$bin_pre}/bin)
end
set path=($cds_bin $path)

foreach lib_pre (${soc_lib_prefix})
   set cds_lib=(${cds_lib}:${cdstop}/{$bin_pre}/lib)
end

if (${?LD_LIBRARY_PATH} == 0) then
   setenv LD_LIBRARY_PATH  ${cds_lib}:/usr/openwin/lib:/usr/dt/lib:/usr/lib:/usr/local/lib
else
   setenv LD_LIBRARY_PATH  ${cds_lib}:${LD_LIBRARY_PATH}
endif

set ldpath = (`echo ${LD_LIBRARY_PATH} | sed -e "s/::*/:/g"`)
setenv LD_LIBRARY_PATH ${ldpath}
setenv ENCOUNTER $cdstop/tools/fe

setenv OA_HOME ${cdstop}/oa

#if (${?CALIBRE_HOME} == 1) then
#       echo Calibre integrated...
#       alias encounter encounter -win -init ${CALIBRE_HOME}/lib/cal_enc.tcl
#endif

unset lmfile
unset ldpath
unset cds_lib
unset cds_bin

