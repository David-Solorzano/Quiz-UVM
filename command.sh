source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh
vcs -Mupdate Testbench.sv  -o salida  -full64 -sverilog  -kdb -debug_acc+all -debug_region+cell+encrypt -l log_test +lint=TFIPC-L -ntb_opts uvm-1.2
./salida
