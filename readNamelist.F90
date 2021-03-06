module CompareNameLists

	CONTAINS

	subroutine readGMNamelists
		implicit none

		integer :: i, k
		integer, parameter :: iun=8

#if __GFORTRAN__==1
#else
		! PGI needs these symbols defined
		integer :: iargc
		external :: iargc
#endif

		character (len=200) :: BUFFER, INFILE

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/pilot.cdk
		character*16 Pil_jobstrt_S,Pil_jobend_S
		logical Pil_sfc2d_L,Pil_3df_L,Pil_bmf_L,Pil_bcs_hollow_L
		integer Pil_nesdt,Pil_hblen,Pil_pil,Pil_maxcfl,Pil_lancemodel
		real    Pil_dx

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_geol/eacid.cdk
		integer acid_i0,acid_in,acid_j0,acid_jn,acid_npas
		logical acid_test_L,acid_pilot_L, &
				acid_readsol_L,acid_readposi_L,Acid_skippospers_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_geol/hybdim.cdk
		logical Vspng_uvwdt_L, Vspng_rwnd_L,Vspng_zmean_L
		integer Vspng_nk, Vspng_niter, Vspng_njpole
		integer, parameter :: Vspng_maxn = 1000
		real :: Vspng_nutop

			! Matt, added the dimension
		real, dimension(Vspng_maxn) :: Vspng_mf, Vspng_nu

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/lam.cdk
		character*16 Lam_runstrt_S,Lam_current_S,Lam_hint_S,Lam_previous_S
		logical Lam_ctebcs_L, Lam_busper_init_L, Lam_toptt_L, &
				Lam_0ptend_L, Lam_blendoro_L   , Lam_cascsfc_L
		integer Lam_nesdt
		real*8  Lam_dtf_8

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/p_serg.cdk
		integer, parameter :: CNSRSFM=256, CNSRPFM=256, CNSRGEO=25
		integer P_serg_srsrf, P_serg_srprf, P_serg_srwri, P_serg_serstp
		integer P_serg_ver
		character*8 P_serg_srsrf_s(cnsrsfm), P_serg_srprf_s(cnsrpfm)
		logical P_serg_sroff_L, P_serg_srsus_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/dimout.cdk
		integer, parameter :: MAXSET=32, MAXELEM=60,MAXGRID=4

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/out3.cdk
		character*16 Out3_xnbits_S(MAXELEM),Out3_filt_S(MAXELEM)
		character*12 Out3_etik_S
		character*4  Out3_unit_S
		logical Out3_cliph_L, Out3_cubzt_L, Out3_cubuv_L, &
			Out3_cubds_L, Out3_cubqs_L, Out3_cubdd_L, Out3_cubqq_L, & 
			Out3_cubww_L, Out3_vt2gz_L, Out3_flipit_L,Out3_debug_L, &
			Out3_compress_L,Out3_satues_L
		integer Out3_nbitg, Out3_linbot, Out3_nundr, Out3_zund(MAXELEM), &
			Out3_filtpass(MAXELEM),Out3_xnbits(MAXELEM),Out3_ndigits, &
			Out3_closestep,Out3_filtpass_max, Out3_xnbits_max,Out3_ip3,Out3_date
		
		integer Out3_lieb_nk, Out3_lieb_maxite
		real    Out3_lieb_conv, Out3_lieb_levels(MAXELEM)
		real    Out3_filtcoef(MAXELEM)


		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/grdc.cdk
		integer, parameter :: max_trnm=1000
		character*4 Grdc_proj_S
		character*4 Grdc_trnm_S(max_trnm)
		character*12 Grdc_nfe
		character*16 Grdc_runstrt_S,Grdc_runend_S
		logical Grdc_bcs_hollow_L,Grdc_initphy_L
		integer Grdc_ni,Grdc_nj,Grdc_iref,Grdc_jref,Grdc_id, &
			Grdc_gid,Grdc_gif,Grdc_gjd,Grdc_gjf,Grdc_ndt,Grdc_gjdi, &
			Grd_ig1c,Grd_ig2c,Grd_ig3c,Grd_ig4c, &
			Grdc_Hblen,Grdc_maxcfl,Grdc_pil,Grdc_end, &
			Grdc_hbwe,Grdc_hbsn,Grdc_start,Grdc_nbits,Grdc_ntr
		real Grdc_latr,Grdc_lonr,Grdc_dx, &
			Grdc_xlat1,Grdc_xlon1,Grdc_xlat2,Grdc_xlon2
		real*8 Grdc_xp1,Grdc_yp1

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/modconst.cdk
		character*16 Mod_runstrt_S


		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_topo.cdk
		logical Topo_filmx_L,Topo_init_L,Topo_dgfmx_L,Topo_dgfms_L,Topo_clip_L
		real, dimension(:), pointer ::  topo ,topou ,topov, &
			topof,topouf,topovf, &
			a_pr_m,i_pr_m,a_ir_m,i_ir_m,a_so_m,i_so_m

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_geol.cdk
		logical  E_geol_glanl_L, E_geol_glreg_L, E_geol_hsanl_L,  &
			E_geol_hscon_L, E_geol_hsreg_L, E_geol_modex_L
		integer  E_geol_hsea, E_geol_poin
		real     E_geol_gls,   E_geol_gln, E_geol_gle ,  E_geol_glw, & 
			E_geol_hss,   E_geol_hsn, E_geol_hse ,  E_geol_hsw , &
			E_geol_z0cst

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_schm.cdk
		logical  e_schm_stlag, e_schm_cocub, e_schm_adcub, &
			e_schm_fgcub, e_Schm_offline_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_anal.cdk
		logical anal_sigma, anal_eta, anal_hyb, anal_pres,anal_perturb
		logical anal_ecmwf, anal_cond
		integer anal_hav

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_offline.cdk
		character*8 Offline_int_accu_S
		integer Offline_ip1a

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_tr.cdk
		integer, parameter :: MAXTR=250
		character*4, dimension(MAXTR)  :: E_tr3d_name_S, E_trname_S
		character(len=6), dimension(MAXTR) :: E_tr3d_list_S ! This one was *50, but I changed it's length to better match the input
		integer E_tr3d_ntr
		real E_tr3d_sval

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/schm.cdk
		logical Schm_hydro_L, Schm_cptop_L, Schm_moist_L, Schm_nkbz_L ,  &
			Schm_phyms_L, Schm_adcub_L, Schm_difqp_L, Schm_psadj_L, &
			Schm_hdlast_L,Schm_wload_L, Schm_pcsty_L, Schm_chems_L, &
			Schm_pheat_L, Schm_theoc_L ,Schm_sfix_L,  Schm_offline_L, &
			Schm_settls_L,Schm_do_step_settls_L 
		integer Schm_itcn , Schm_modcn, Schm_xwvt3,  &
			Schm_itnlh, Schm_itraj, Schm_nith, &
			Schm_settls_opt,Schm_settls_freq
		real*8  Schm_nonhy_8

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/itf_phy_config.cdk
		character*16  P_pbl_schsl_S,P_pbl_schurb_S, &
			P_pbl2_schsl_S,P_cond_stcon_s
		logical P_cond_satu_L, P_pbl_snoalb_L, P_pbl_iceme_L, &
			P_pbl_icelac_L,P_pbl_ocean_L , P_pbl2_iceme_L, &
			P_offline_adapt_L
		integer P_fcpkuo_xofset, P_fcpkuo_xblnd, P_out_moyhr, &
			P_fcpkuo_yofset, P_fcpkuo_yblnd, P_pbd_dumpbus
		real*8  p_lmvd_valml_8  ,p_lmvd_mllat_8, &
			p_lmvd_valeq_8  ,p_lmvd_eqlat_8, &
			p_offline_filtpr_8
		logical  P_pset_second_L
		integer  P_pset_xofset, P_pset_xofsetr, &
			P_pset_yofset, P_pset_yofsett, &
			P_pset_xblnd , P_pset_yblnd

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_mta.cdk
		logical E_intwind_mta_L, E_same_size_L, E_force_read_image_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/glb_ld.cdk
		logical G_lam, G_periodx, G_periody
		integer G_ni, G_nj, G_nk, G_niu, G_njv, G_lnimax, G_lnjmax, &
			G_halox, G_haloy
		real*8 G_xg_8, G_yg_8

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/hblen.cdk
		character*16 Hblen_wfct_S
		integer Hblen_x,Hblen_y, &
			Hblen_momentx,Hblen_momenty,Hblen_tx,Hblen_ty, &
			Hblen_massx,Hblen_massy,Hblen_trx,Hblen_try

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/hybdim.cdk
		integer, parameter :: maxhlev=1024
		real, dimension(maxhlev) :: hyb

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/hzd.cdk
		character*12 Hzd_type_S
		logical Hzd_fact_L,Hzd_ho_L,Hzd_difva_L,Hzd_uvwdt_L,Hzd_rwnd_L, &
			Hzd_t1_0_L,Hzd_t1_1_L,Hzd_t0_0_L,Hzd_t0_1_L, &
			Hzd_1d_L,Hzd_hdif0_0_L,Hzd_hdif0_1_L, &
			Hzd_hzdmain_0_L,Hzd_hzdmain_1_L
		integer Hzd_pwr,Hzd_numerical_poles_nlat,Hzd_numerical_poles_mask
		real Hzd_lnR,Hzd_cdiff,Hzd_numerical_poles_hyb

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/sol.cdk
		character*26 sol_type_S,sol_precond_S
		logical sol_fft_L
		integer sol_pil_w,sol_pil_e,sol_pil_n,sol_pil_s, &
			sol_niloc,sol_njloc,sol_nloc,sol_maxits,     &
			sol_im,sol_i0,sol_in,sol_j0,sol_jn
		real*8 sol_eps

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/xst.cdk
		integer, parameter :: MAXSTAT=999
		integer Xst_nstat,Xst_dimsers,Xst_dimserp,xst_nstatl 
		integer Xst_statij(2,MAXSTAT),Xst_istat (MAXSTAT), &
			Xst_jstat   (MAXSTAT),Xst_lclsta(MAXSTAT), &
			xst_stcori  (MAXSTAT),xst_stcorj(MAXSTAT)
		real    Xst_statll(2,MAXSTAT)

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/zblen.cdk
		real Zblen_hmin,Zblen_spngthick
		logical Zblen_L, Zblen_spngtt_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/p_zong.cdk
		integer, parameter :: CNZNSFM = 40, CNZNPFM = 40
		integer P_zong_znli,  P_zong_znsrf, P_zong_znprf, &
			P_zong_znmod, P_zong_nbin
		character*4 P_zong_znsrf_s(CNZNSFM), P_zong_znprf_s(CNZNPFM)
		logical P_zong_znsus_l,P_zong_znoff_L

		! Source /home/dormrb02/modeles/PHY+/v_5.0.4.2/RCS/maxlev.cdk,v
		INTEGER, PARAMETER :: LEVMAX = 200

		! Source /home/dormrb02/modeles/PHY+/v_5.0.4.2/RCS/options.cdk,v
		INTEGER           ICONVEC,IFLUVERT,IGWDRAG,IKFCPCP,ILONGMEL,IOPTIX
		INTEGER           IPCPTYPE,IRADIA,ISCHMSOL,ISCHMURB,ISHLCVT(2)
		INTEGER           ISTCOND
		!
		CHARACTER*16      OPTIONS_CHARACTER_FIRST(-1:0), OPTIONS_FILE_FIRST(-1:0)
		CHARACTER*16      CONVEC, FLUVERT, GWDRAG, KFCPCP, LONGMEL, OPTIX
		CHARACTER*16      PCPTYPE, RADFILES, RADIA, SCHMSOL, SCHMURB
		CHARACTER*16      SHLCVT(2), STCOND
		CHARACTER*16      OPTIONS_CHARACTER_LAST, OPTIONS_FILE_LAST
		CHARACTER*1024    OZONE_FILE_S
		INTEGER           CW_RAD,DATE(14),IHEATCAL,KNTRAD
		INTEGER           LIN_KPH,LIN_LSC,LIN_PBL,LIN_SGO,LIN_V4D
		INTEGER           MY_CCNTYPE,MY_FULL_VERSION,MOYHR, NSLOFLUX
		INTEGER           RADNIVL(LEVMAX+1)
		LOGICAL           ADVECTKE,AGREGAT,BKGALB
		LOGICAL           CHAUF,CLIMAT,CORTM,COUPLING,DBGMEM,DIFFUW,LMETOX
		LOGICAL           DRAG,DRYLAPS,EVAP,FOMIC,ICELAC,IMPFLX
		LOGICAL           ICEMELT, INILWC, KFCMOM,KTICEFRAC,KFCTRIGLAT
		LOGICAL           LIMSNODP
		LOGICAL           MY_DIAGON,MY_ICEON,MY_INITN,MY_RAINON,MY_SEDION
		LOGICAL           MY_SNOWON,MY_WARMON,MY_DBLMOM_C,MY_DBLMOM_R
		LOGICAL           MY_DBLMOM_I,MY_DBLMOM_S,MY_DBLMOM_G,MY_DBLMOM_H
		LOGICAL           NON_ORO,OFFLINE,OFFLINE_ADAPT,OWFLUX
		LOGICAL           RADFIX,RADFLTR,RADSLOPE,REDUC,SALTY_QSAT,SATUCO
		LOGICAL           SIMISCCP,SNOALB_ANL,SNOWMELT,STOMATE,STRATOS
		LOGICAL           TDIAGLIM,TSCONFC,TS_FLXIR,TYPSOL,WET,Z0DIR
		LOGICAL           Z0TRDPS300
		REAL              AS2,BETA2,DELT,DZSEDI,EPONGE(LEVMAX),ETRMIN2
		REAL              FACDIFV,FACTDT,HC2,HF2,HM2,KFCTRIG4(4),KFCTRIGA
		REAL              KFCTRIGL, KFCRAD,KFCDEPTH, KFCDET
		REAL              KFCDLEV, KFCTIMEC, KFCTIMEA, KKL2
		REAL              MY_DZSEDI, OFFLINE_LAPSERATE
		REAL              PARSOL(6),PBL_RICRIT(2),PTOP_NML,QCO2,QCH4,QN2O,QCFC11,QCFC12
		REAL              RMSCON,TAUFAC,TRIGLAT(2),Z0MIN2,Z0TLAT(2),ZTA,ZUA

		! Source /home/dormrb02/modeles/PHY+/v_5.0.4.2/RCS/phy_master_ctrl.cdk,v
		character*24 phy_pck_version,phy_release_pck_version
		integer phy_init_ctrl

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/grd.cdk
		character*2 Grd_typ_S, Grd_proj_S
		character*256 Grd_filename_S
		logical Grd_roule, Grd_uniform_L, Grd_gauss_L
		integer Grd_ni, Grd_nj, Grd_nila, Grd_njla, Grd_left, Grd_belo, &
			Grd_iref, Grd_jref
		real Grd_dx, Grd_dy, Grd_dxmax, Grd_dymax, &
			Grd_latr, Grd_lonr, Grd_x0, Grd_xl, Grd_y0, Grd_yl, &
			Grd_xlon1, Grd_xlat1, Grd_xlon2, Grd_xlat2, Grd_rot, Grd_rcoef
		real*8 Grd_rot_8
		integer Grd_ni_glb,Grd_nj_glb,Grd_subset_i_ref,Grd_subset_j_ref
		logical Grd_subset_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/v2dzd.cdk
		integer :: v2dzd_pole_n
		real :: V2dzd_pole_fact

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/vrtd.cdk
		logical Vrtd_L, Vrtd_theta_L
		real Vrtd_coef

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/offc.cdk
		real*8  Offc_a0_8 , Offc_a1_8 , Offc_b0_8 , Offc_b1_8

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/cori.cdk
		logical Cori_cornl_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/clim.cdk
		logical Clim_climat_L, Clim_inincr_L

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/init.cdk
		logical  Init_balgm_L, Init_dfwin_L, Init_dftr_L
		integer  Init_dfnp
		real*8   Init_dfpl_8

		! Source /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/cstv.cdk
		real*8    Cstv_dt_8, Cstv_tau_8, Cstv_tstr_8, &
			Cstv_pitop_8, Cstv_pisrf_8, Cstv_uvdf_8, Cstv_phidf_8, &
			Cstv_hco0_8, Cstv_hco1_8

		! Guessed type based on value (except for characters, I looked them up)
		character(len=64) :: Adw_interp_type_S
		integer ::  Adw_halox, Adw_haloy, Hspng_nj, Lctl_reset, Mem_mx3db
		integer :: Step_bkup, Step_cleanup, Step_gstat, Step_maxcfl, Step_rsti, Step_spinphy, Step_total, Tr3d_ntr, Vtopo_ndt, Vtopo_start
		logical :: Adw_RB_positions_L, Adw_ckbd_L, Adw_exdg_L, Adw_mono_L, Adw_nkbz_L, Adw_nosetint_L
		logical :: Eigv_parity_L, Hspng_uvwdt_L
		logical :: Lctl_debug_L, Lctl_r8stat_L, Level_ip12000_L, Pres_vtap_L, Rstri_glbcol_L
		logical :: Step_cliptraj_L
		real ::  Hspng_mf, Pres_pref, Pres_ptop

		! Added by Matt, as these were only found in the Olympic runs
		integer :: Glb_pil_n=0, Glb_pil_e=0, Glb_pil_s=0, Glb_pil_w=0


	!	if ((F_namelistf_S.eq.'print').or.(F_namelistf_S.eq.'PRINT')) then
	!		e_gement_nml = 0
	!		write (6,nml=gement_p)
	!		return
	!	endif


		! Taken from /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_nml.cdk
		namelist /gement/     &
		Anal_cond, Anal_perturb, E_force_read_image_L , &
		E_geol_glanl_L, E_geol_glreg_L, &
		E_geol_gle    , E_geol_gln    , E_geol_gls    , E_geol_glw  , &
		E_geol_hsanl_L, E_geol_hscon_L, E_geol_hse    , E_geol_hsea , &
		E_geol_hsn    , E_geol_hsreg_L, E_geol_hss    , E_geol_hsw  , &
		E_geol_modex_L, E_geol_poin   , E_geol_z0cst  , &
		E_intwind_mta_L,E_schm_adcub  , E_schm_stlag, &
		E_tr3d_list_S , &
		Mod_runstrt_S , Offline_ip1a  , Offline_int_accu_S, &
		Pil_3df_L     , Pil_bcs_hollow_L, Pil_bmf_L    , Pil_dx     , &
		Pil_hblen     , Pil_jobend_S    , Pil_jobstrt_S,  &
		Pil_maxcfl    , Pil_lancemodel  , Pil_nesdt    , Pil_sfc2d_L, &
		Schm_offline_L,p_offline_filtpr_8, &
		Topo_dgfms_L  ,Topo_dgfmx_L, Topo_filmx_L, Topo_init_L, Topo_clip_L, &
		Pil_pil ! Added by Matt, while declared in pilot.cdk, it's only part of the namelist in the Olympic runs.
	
	
		! Taken from /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/nml.cdk
		! Some defaults in gem_nml.ftn
		namelist /gem_cfgs/ &
		Acid_test_L, &
		Adw_ckbd_L, Adw_exdg_L, &
		Adw_halox,  Adw_haloy, &
		Adw_interp_type_S, Adw_mono_L, Adw_nkbz_L, &
		Adw_nosetint_L,Adw_RB_positions_L,     &
		Clim_climat_L, Clim_inincr_L, &
		Cori_cornl_L, &
		Cstv_dt_8,    Cstv_phidf_8, Cstv_pisrf_8, &
		Cstv_pitop_8, Cstv_tstr_8, Cstv_uvdf_8,  &
		Eigv_parity_L, &
		G_halox,       G_haloy, &
		Grd_rcoef, &
		Hblen_x,       Hblen_y, &
		Hspng_mf,      Hspng_nj,   Hspng_uvwdt_L, &
		HYB, &
		Hzd_1d_L,      Hzd_difva_L, &
		Hzd_hdif0_0_L, Hzd_hdif0_1_L, &
		Hzd_hzdmain_0_L,             Hzd_hzdmain_1_L, &
		Hzd_lnr,       Hzd_pwr, &
		Hzd_t0_1_L,    Hzd_t0_0_L,   Hzd_t1_0_L,   Hzd_t1_1_L, &
		Hzd_type_S,    Hzd_uvwdt_L,  Hzd_rwnd_L, &
		Hzd_numerical_poles_nlat, Hzd_numerical_poles_mask, Hzd_numerical_poles_hyb, &
		Init_balgm_L,  Init_dfwin_L, Init_dfnp, &
		Init_dfpl_8,   Init_dftr_L, &
		Lam_0ptend_L,  Lam_ctebcs_L, Lam_hint_S    , Lam_nesdt, &
		Lam_runstrt_S, Lam_toptt_L , Lam_blendoro_L, Lam_cascsfc_L, &
		Lctl_debug_L,  Lctl_r8stat_L,Lctl_reset, &
		Level_ip12000_L, &
		Mem_mx3db, &
		Offc_a0_8,     Offc_a1_8,  &
		Offc_b0_8,     Offc_b1_8, &
		Out3_cliph_L,  Out3_closestep,  Out3_compress_L, &
		Out3_cubdd_L,  Out3_cubds_L, Out3_cubqq_L,  Out3_cubqs_L, &
		Out3_cubuv_L,  Out3_cubww_L, Out3_cubzt_L, &
		Out3_debug_L,  Out3_etik_S,  Out3_flipit_L, Out3_ip3,  &
		Out3_linbot,   Out3_nbitg,   Out3_ndigits,  Out3_satues_L, &
		Out3_unit_S,   Out3_vt2gz_L, Out3_zund, Out3_lieb_levels, &
		Out3_lieb_maxite, Out3_lieb_conv, &
		Pres_ptop,     Pres_vtap_L, &
		Rstri_glbcol_L, &
		Schm_adcub_L,  Schm_difqp_L,    Schm_hdlast_L,  &
		Schm_itcn,     Schm_itnlh,      Schm_itraj, &
		Schm_hydro_L,  Schm_modcn,      Schm_moist_L,  Schm_nonhy_8, &
		Schm_pcsty_L,  Schm_pheat_L,    Schm_psadj_L, &
		Schm_settls_L, Schm_settls_opt, Schm_settls_freq,  &
		Schm_sfix_L,   Schm_wload_L,    Schm_xwvt3, &
		Sol_eps,       Sol_fft_L,       Sol_im, &
		Sol_maxits,    Sol_precond_S,   Sol_type_S, &
		Step_bkup,     Step_cleanup,    Step_spinphy, &
		Step_gstat,    Step_rsti,       Step_total, &
		Step_maxcfl,   Step_cliptraj_L, &
		Vspng_mf,      Vspng_njpole,    Vspng_nk,     Vspng_nutop, &
		Vspng_rwnd_L,  Vspng_uvwdt_L,   Vspng_zmean_L, &
		Vtopo_ndt,     Vtopo_start, &
		Vrtd_L,        Vrtd_coef,       Vrtd_theta_L, &
		V2dzd_pole_n,  V2dzd_pole_fact, &
		Xst_statij,    Xst_statll,  &
		Zblen_L,       Zblen_spngthick, Zblen_spngtt_L, &
		P_fcpkuo_xblnd,P_fcpkuo_xofset, &
		P_fcpkuo_yblnd,P_fcpkuo_yofset, &
		P_lmvd_valml_8,P_lmvd_mllat_8, &
		P_lmvd_valeq_8,P_lmvd_eqlat_8,P_offline_filtpr_8, &
		P_pbd_dumpbus, &
		P_pset_second_L, &
		P_pset_xblnd,  P_pset_xofset, P_pset_xofsetr, &
		P_pset_yblnd,  P_pset_yofset, P_pset_yofsett, &
		P_serg_serstp, &
		P_serg_srprf_s,P_serg_srsrf_s,P_serg_srsus_L, &
		P_serg_srwri, &
		P_zong_nbin,    P_zong_znli,    P_zong_znmod, &
		P_zong_znprf_s, P_zong_znsrf_s, P_zong_znsus_L, &
		Glb_pil_n, Glb_pil_e, Glb_pil_s, Glb_pil_w ! Added by Matt, as these were only found in the Olympic runs

		! Taken from /home/dormrb02/modeles/PHY+/v_5.0.4.2/RCS/phy_namelist.cdk,v
		NAMELIST /PHYSICS_CFGS/                                     &
		ADVECTKE,AGREGAT,AS2,BETA2,BKGALB,CHAUF,CONVEC,          &
		CORTM,DBGMEM,DIFFUW,DRAG,DRYLAPS,DZSEDI,EPONGE,ETRMIN2,  &
		EVAP,FACDIFV,FACTDT,FLUVERT,FOMIC,GWDRAG,HC2,HF2,HM2,    &
		ICELAC,ICEMELT,IHEATCAL,IMPFLX,INILWC,KFCDEPTH,KFCDET,   &
		KFCDLEV,KFCMOM,KFCPCP,KFCRAD,KFCTIMEA,KFCTIMEC,          &
		KFCTRIG4,KFCTRIGA,KFCTRIGL,KFCTRIGLAT,KKL2,KNTRAD,       &
		KTICEFRAC,LIMSNODP,                                      &
		LMETOX,LONGMEL,MOYHR,MY_CCNTYPE,MY_DBLMOM_C,             &
		MY_DBLMOM_G,MY_DBLMOM_H,MY_DBLMOM_I,MY_DBLMOM_R,         &
		MY_DBLMOM_S,MY_DIAGON,MY_DZSEDI,MY_FULL_VERSION,MY_ICEON,&
		MY_INITN,MY_RAINON,MY_SEDION,MY_SNOWON,MY_WARMON,MOYHR,  &
		NON_ORO,NSLOFLUX,OFFLINE_ADAPT,OFFLINE_LAPSERATE,OWFLUX, &
		PARSOL,PBL_RICRIT,PCPTYPE,PHY_PCK_VERSION,               &
		QCFC11,QCFC12,QCH4,QCO2,QN2O,RADFILES,RADFIX,RADFLTR,    &
		RADIA,RADNIVL,RADSLOPE,                                  &
		RMSCON,SALTY_QSAT,SATUCO,SCHMSOL,SCHMURB,SHLCVT,         &
		SIMISCCP,SNOALB_ANL,SNOWMELT,STCOND,STOMATE,STRATOS,     &
		TAUFAC,TDIAGLIM,TS_FLXIR,TSCONFC,TRIGLAT,TYPSOL,Z0DIR,   &
		Z0TRDPS300,Z0MIN2,Z0TLAT,ZTA,ZUA

		! Defaults values for gement namelist variables
		! Taken from /home/dormrb02/modeles/GEMDM_shared+/v_3.3.8.2/src/e_gement_nml.ftn
		Mod_runstrt_S ='@#$%'
		Pil_jobstrt_S ='@#$%'
		Pil_jobend_S  ='@#$%'
		Pil_sfc2d_L      = .true.
		Pil_3df_L        = .true.
		Pil_bcs_hollow_L = .true.
		Pil_bmf_L        = .false.
		Pil_dx           = 0.0
		Pil_maxcfl       = 1
		Pil_nesdt        = 0
		Pil_hblen        = 10
		Pil_lancemodel   = 10000

		Topo_filmx_L= .true.
		Topo_init_L = .true.
		Topo_dgfmx_L= .false.
		Topo_dgfms_L= .true.
		Topo_clip_L = .true.

		Anal_cond       = .false.
		anal_perturb    = .false.
		E_schm_stlag    = .true.
		E_schm_adcub    = .true.
		Schm_offline_L  = .false.
		E_geol_glanl_L  = .true.
		E_geol_glreg_L  = .false.
		E_geol_hsanl_L  = .true.
		E_geol_hscon_L  = .false.
		E_geol_hsreg_L  = .true.
		E_geol_gls  = 30.
		E_geol_gln  = 80.
		E_geol_glw  = 220.
		E_geol_gle  = 320.
		E_geol_hss  = 30.
		E_geol_hsn  = 80.
		E_geol_hsw  = 220.
		E_geol_hse  = 320.
		E_geol_hsea = 3000
		E_geol_poin = 3
		E_geol_modex_L = .false.
		E_geol_z0cst   = -1.
		P_offline_filtpr_8 = 0.0

		Offline_int_accu_S = 'LINEAR'
		Offline_ip1a = 11950   

		E_tr3d_list_S = ''

		E_intwind_mta_L      = .FALSE.
		E_force_read_image_L = .FALSE.


		!
		! Defaults values for var4d namelist variables
		!
		Step_total = 1
		Step_rsti  = 9999999
		Step_bkup  = 9999999
		Step_gstat = 9999999
		Step_spinphy=9999999
		Step_cleanup = 0
		Step_maxcfl  = 1
		Step_cliptraj_L = .false.

		Rstri_glbcol_L = .false.

		Mem_mx3db    = -1

		G_halox = 4
		G_haloy = G_halox

		Hblen_wfct_S  = 'COS2'
		Hblen_x = 10
		Hblen_y = Hblen_x

		Init_balgm_L = .false.
		Init_dfwin_L = .true.
		Init_dfnp    = 5
		Init_dfpl_8  = 21600.0
		Init_dftr_L  = .false.

		Offc_a0_8 =  1.0
		Offc_a1_8 = -1.0
		Offc_b0_8 =  0.6
		Offc_b1_8 =  0.4

		Schm_hydro_L    = .false.
		Schm_nonhy_8    = 1.0
		Schm_moist_L    = .true.
		Schm_hdlast_L  = .false.
		Schm_itcn     =   2
		Schm_modcn    =   1
		Schm_xwvt3    = 0
		Schm_itnlh    = 2
		Schm_itraj    = 2
		Schm_adcub_L    = .true.
		Schm_psadj_L    = .false.
		Schm_difqp_L    = .true.
		Schm_wload_L    = .false.
		Schm_pcsty_L    = .true.

		Schm_pheat_L    = .true.
		Schm_sfix_L     = .false.
		Schm_settls_L   = .false.
		Schm_settls_opt = 2
		Schm_settls_freq= 2

		Schm_phyms_L    = .false.
		Schm_chems_L    = .false.

		Lam_hint_S    = 'CUB_LAG'
		Lam_runstrt_S = '@#$%'
		Lam_nesdt     = -1
		Lam_ctebcs_L  = .false.
		Lam_toptt_L   = .false.
		Lam_0ptend_L  = .true.
		Lam_blendoro_L= .true.
		Lam_cascsfc_L = .true.
		Lam_busper_init_L  = .false.
		Lam_current_S = '20000101.000000'

		Zblen_L   = .false.

		Adw_nkbz_L = .true.
		Adw_exdg_L = .false.
		Adw_ckbd_L = .false.
		Adw_mono_L = .true.
		Adw_interp_type_S = 'lag3d'
		Adw_nosetint_L   = .false.
		Adw_halox  = 3
		Adw_haloy  = 2
		Adw_RB_positions_L = .false.

		Clim_climat_L  = .false.
		Clim_inincr_L  = .false.

		Cori_cornl_L = .true.

		Cstv_dt_8    = 900
		Cstv_uvdf_8  = 20000.
		Cstv_phidf_8 = 20000.
		Cstv_pitop_8 = -1.0
		Cstv_pisrf_8 = 1000.0
		Cstv_tstr_8  =  200.0

		Lctl_r8stat_L   = .false.
		Lctl_debug_L    = .false.
		Lctl_reset      = -1

		Acid_test_L        = .false.
		Acid_skippospers_L = .false.

		Acid_readsol_L     = .false.
		Acid_readposi_L    = .false.
		Acid_pilot_L       = .false.
		Acid_i0         = 0
		Acid_in         = 0
		Acid_j0         = 0
		Acid_jn         = 0
		Acid_npas       = 0

		Level_ip12000_L = .false.

		Grd_rcoef = 1.0
		Grd_proj_S = 'E'
		Pres_ptop = -1.
		Pres_pref = 800.0
		Pres_vtap_L = .false.
		do k = 1, maxhlev
			hyb(k) = -1.
		end do

		sol_fft_L     = .true.
		sol_type_S    = 'DIRECT'
		sol_precond_S = 'JACOBI'
		sol_eps       = 1.d-09 
		sol_im        = 15
		sol_maxits    = 200

		Eigv_parity_L = .false.
		Hzd_type_S = "HO"
		Hzd_difva_L= .false.
		Hzd_pwr    = 6
		Hzd_lnr    = 0.2
		Hzd_uvwdt_L= .true.
		Hzd_rwnd_L = .false.
		Hzd_numerical_poles_nlat = 0
		Hzd_numerical_poles_mask = 1 
		Hzd_numerical_poles_hyb  =.1 
		Hspng_nj = 0
		Hspng_mf = 800.
		Hspng_uvwdt_L  = .true.
		Vspng_nk = 0
		do i = 1, Vspng_maxn
			Vspng_mf(i) = -1.
			Vspng_nu(i) = -1.
		end do
		Vspng_nutop = -1.
		Vspng_uvwdt_L  = .true.
		Vspng_rwnd_L   = .false.
		Vspng_njpole   = 3
		Vspng_zmean_L  = .false.



		Hzd_t1_0_L = .false.
		Hzd_t1_1_L = .false.
		Hzd_t0_0_L = .false.
		Hzd_t0_1_L = .false.
		Hzd_1d_L   = .false.
		Hzd_hdif0_0_L   = .false.
		Hzd_hdif0_1_L   = .false.
		Hzd_hzdmain_0_L = .true.
		Hzd_hzdmain_1_L = .true.

		Vrtd_L         = .false.
		Vrtd_theta_L   = .false.
		Vrtd_coef      = 1.

		Vtopo_start = -1
		Vtopo_ndt = 0

		V2dzd_pole_n=-1
		V2dzd_pole_fact=1.

		Tr3d_ntr = 0

		P_fcpkuo_xofset  = Grd_left
		P_fcpkuo_xblnd   = 1
		P_fcpkuo_yofset  = Grd_belo
		P_fcpkuo_yblnd   = 1
		p_lmvd_valml_8  = 1.0
		p_lmvd_mllat_8  = 30.0
		p_lmvd_valeq_8  = 1.0
		p_lmvd_eqlat_8  = 5.0
		P_pset_second_L= .false.
		P_pset_xofset  = 0
		P_pset_yofset  = 0
		P_pset_xofsetr =-1
		P_pset_yofsett =-1
		P_pset_xblnd   = 1
		P_pset_yblnd   = 1
		P_pbd_dumpbus  = 0

		P_serg_srsus_L    = .false.
		P_serg_srsrf_s = ' '
		P_serg_srprf_s = ' '
		P_serg_srwri      = 1
		P_serg_serstp     = 99999

		P_zong_znli = 0
		P_zong_nbin = min( Grd_nj,Grd_ni )
		P_zong_znmod = 1

		P_zong_znoff_L = .false.
		P_zong_znsus_L = .false.
		P_zong_znsrf_s = ' '
		P_zong_znprf_s = ' '

		do i = 1,MAXSTAT
		Xst_statij(1,i) = -9999
		Xst_statij(2,i) = -9999
		Xst_statll(1,i) = -9999.0
		Xst_statll(2,i) = -9999.0
		enddo

		do i = 1,MAXELEM
			Out3_zund(i)        = 0
			Out3_lieb_levels(i) = 0.
		enddo
		Out3_lieb_conv   = 0.1
		Out3_lieb_maxite = 100

		Out3_etik_S    = 'GEMDM'
		Out3_unit_S    = ' '
		Out3_closestep = -1
		Out3_ndigits   = -1
		Out3_ip3       = 0
		Out3_nbitg     = 16
		Out3_linbot    = 0
		Out3_cliph_L   = .false.
		Out3_satues_L  = .false.
		Out3_vt2gz_L   = .false.
		Out3_cubzt_L   = .true.
		Out3_cubuv_L   = .true.
		Out3_cubds_L   = .true.
		Out3_cubqs_L   = .true.
		Out3_cubdd_L   = .true.
		Out3_cubqq_L   = .true.
		Out3_cubww_L   = .true.
		Out3_debug_L   = .false.
		Out3_flipit_L  = .false.
		Out3_compress_L= .false.

		Grdc_proj_S = 'L'
		Grdc_xlat1  = Grd_xlat1
		Grdc_xlon1  = Grd_xlon1
		Grdc_xlat2  = Grd_xlat2
		Grdc_xlon2  = Grd_xlon2 
		Grdc_ni     = 0
		Grdc_nj     = 0
		Grdc_Hblen  = 10
		Grdc_maxcfl = 1
		Grdc_nfe    = ''
		Grdc_initphy_L = .false.

		Grdc_runstrt_S = Lam_runstrt_S
		Grdc_runend_S  = Lam_runstrt_S
		Grdc_bcs_hollow_L = .true.
		Grdc_nbits = 32 

		! End of defaults
		!



		I = IARGC();
		WRITE(6,'(A,I2,A)') "Received ", I, " arguments"
		IF (I > 1) THEN
			WRITE(0,*) "Syntax error."; 
			WRITE(0,*) "readNamelist [<namelist file>]";
			STOP " "
		END IF


		! Print out namelist defaults


		! Read in namelist file
		if (I == 1) then
			CALL GETARG(1, BUFFER);
			read(buffer,'(A)') INFILE
			!write(6, '(2A)') "Buffer ", trim(BUFFER)
			write(6, '(2A)') "Reading ", trim(INFILE)
			open(iun, file=INFILE, status='OLD', recl=80, delim='APOSTROPHE')
			!read(iun, nml=gement, end=9110, err=9111)
			read(iun, nml=gement)
			read(iun, nml=gem_cfgs)
			read(iun, nml=physics_cfgs)
		else
			write(6, '(A)') 'Printing defaults'
		endif

		write(6,nml=gement)
		write(6,nml=gem_cfgs)
		write(6,nml=physics_cfgs)

		STOP "Done"
	!9111 write (6, 8150) "here at 9111"
	!9110 write (6, 8150) trim(INFILE)
	!8150 format (/,' NAMELIST <namelist>    INVALID IN FILE: ',a)
	!8155 format (/,' FILE: ', a, ' NOT AVAILABLE')

	endsubroutine
endmodule CompareNameLists
