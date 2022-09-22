      * ------------------------------------------------------------------------
      * Programa...: FCORSOLAR
      * Autor......: 
      * Fecha......: 20220922
      * Descripción: Mantenimiento Solicitud(Archivo SOLAR)
      * ------------------------------------------------------------------------
      * Metodo de creación: Se compila con 14 con los siguientes parámetros
      * COMMIT(*NONE) CLOSQLCSR(*ENDMOD) DBGVIEW(*SOURCE)
      * ------------------------------------------------------------------------
      * AAAA-MM-DD  Autor
      * Descripción del cambio
      * ------------------------------------------------------------------------

      *- Directivas de Compilación ---------------------------------------------
     HOption(*NoDebugIO)
     HDftActGrp(*No) ActGrp(*Caller)

      *- Archivos --------------------------------------------------------------
     FFCODSSOLARCF   E             Workstn SFile(SFL:w_NRR)
     FSOLARC    UF A E           K Disk    UsrOpn ExtFile(WBiblCon)

      *- Prototipos Internos ---------------------------------------------------
     DPr_Prepare       Pr
     DPr_LimpiaSFL     Pr
     DPr_LlenaPagina   Pr
     DPr_AsignaSFL     Pr
     DPr_Opciones      Pr
     DPr_Posiciona     Pr
     DPr_Crear         Pr
     DPr_Modificar     Pr
     DPr_Eliminar      Pr
     DPr_Consultar     Pr
     DFn_Valida        Pr              N
     DFn_Centrar       Pr            50a
     D  p_Texto                      50a   Const

     DPr_LogDFU        Pr                  ExtPgm('FCORLOGDFU')
     D  p_RegAnt                    680A
     D  p_RegDesp                   680A
     D  P_Opera                      10A
     D  P_Libreria                   10A
     D  P_Archivo                    10A

     D  w_RegAnt       s            680A   Inz(*Blanks)
     D  w_RegDesp      s            680A   Inz(*Blanks)
     D  w_Opera        s             10A
     D  w_Libreria     s             10A
     D  w_Archivo      s             10A

      *- Estructuras de Datos --------------------------------------------------
      *-- Estructuras Especiales
     D Ds_Tabla      E Ds                  ExtName(SOLARC) Qualified
     D Ds_TablaQ     E Ds                  ExtName(SOLARC) Qualified

     D Ds_As400       sDs                  Qualified
     D  PGM              *Proc
     D  Wrkst                244    253
     D  Usr                  254    263
     D Todo                    1    500
      // Definicion de Indicadores
     Dptr              S               *   Inz(%addr(*In))
     D@ind             DS                  Based(ptr)
     D Ind_F3                          N   Overlay(@Ind:03)
     D Ind_TecVolver                   N   Overlay(@Ind:05)
     D Ind_TecCrear                    N   Overlay(@Ind:06)
     D Ind_TecConfirm                  N   Overlay(@Ind:10)
     D Ind_TecElimina                  N   Overlay(@Ind:23)
     D Ind_TecSalir                    N   Overlay(@Ind:12)
     D Ind_TecAvPag                    N   Overlay(@Ind:25)
     D Ind_TecRePag                    N   Overlay(@Ind:26)
     D*
     D Ind_ProteClave                  N   Overlay(@Ind:30)
     D Ind_ProteCampo                  N   Overlay(@Ind:31)
     D*
     D Ind_MuestraSFL                  N   Overlay(@Ind:40)
     D Ind_MuestraCtl                  N   Overlay(@Ind:41)
     D Ind_FinSFL                      N   Overlay(@Ind:42)
     D Ind_LimpiaSFL                   N   Overlay(@Ind:43)
     D Ind_MsgFinSFL                   N   Overlay(@Ind:44)
     D Ind_MsgIniSFL                   N   Overlay(@Ind:45)
     D Ind_MsgAgrega                   N   Overlay(@Ind:46)
     D Ind_MsgModifi                   N   Overlay(@Ind:47)
     D Ind_MsgElimin                   N   Overlay(@Ind:48)
     D*
     D Ind_MsgNoFound                  N   Overlay(@Ind:50)
     D Ind_ErrCedula                   N   Overlay(@Ind:51)
     D Ind_ErrNombre                   N   Overlay(@Ind:52)
     D Ind_ErrOculto                   N   Overlay(@Ind:55)
     D Ind_ErrFondo                    N   Overlay(@Ind:56)
     D Ind_ErrSolici                   N   Overlay(@Ind:58)
     D Ind_Errexiste                   N   Overlay(@Ind:59)
     D Ind_ErrOficina                  N   Overlay(@Ind:60)
     D*
     D Ind_PermiteAvP                  N   Overlay(@Ind:80)
     D Ind_PermitConf                  N   Overlay(@Ind:81)
     D Ind_PermitElim                  N   Overlay(@Ind:83)
     D Ind_PermitF3                    N   Overlay(@Ind:82)
      *- Variables y Constantes ------------------------------------------------
     D w_NRR           s              4s 0
     D w_UltNrr        s              4s 0 Inz(0)
     D w_LLenarSfl     s              1a
     D w_StrTabla      s           1000a
     D w_StrFiltro     s           1000a
     D w_StrOrden      s            500a
     D w_StrOptimize   s             50a
     D w_StrSQL        s           2000a
     D w_posid1        s              3a
     D w_posid2        s              8a
     D w_posid3        s              9s 0
     D c_Com           C                   Const('''')
     D WBiblCon        s             21A
      *Parámetros de Entrada
     C     *ENTRY        PLIST
     C                   Parm                    Libreria         10

      /Free
       //-----------------------------------------------------------------------
       //Bloque Principal
       //-----------------------------------------------------------------------
        //Asigna el registro de Titulos
        DNOMPGM = Ds_As400.PGM;
        DTITULO1 = Fn_Centrar('BANCOLOMBIA');
        DTITULO2 = Fn_Centrar('Fondos de Inversión');

        w_Archivo = 'SOLARC';
        //Apertura del Archivo según librería recibida por parametro.

        WBiblCon = %Trim(Libreria) + '/SOLARC';
        If %Open (SOLARC);
           Close SOLARC;
        EndIf;
        If Not %Open (SOLARC);
           Open SOLARC;
        EndIf;

       //Declara cursor para recorrer el archivo para la consulta.
       //Dinamicamente Selecciona los registros en el orden requerido
        //Tabla y Campo
         w_StrTabla = 'Select *';
         w_StrTabla = %Trim(w_StrTabla)+ ' FROM ' +  %Trim(WBiblCon);
        //Ordenamiento
         w_StrOrden = 'ORDER BY  SOLCOD';
        // Optimizar SQL
         w_StrOptimize = ' For Read Only' +
                        ' Optimize For 1000 Rows';
        //Prepara SQL y Crea Cursor
        Pr_Prepare();
        w_LLenarSfl = 'S';

        //Ciclo mostrando la Pantalla y validando acciones del usuario
        DoW '1';
           If w_LLenarSfl = 'S';
             Pr_LimpiaSFL();
             Pr_LlenaPagina();
           EndIf;
           //Controla errores en posicionamiento del Subfile
           If D01POS > w_UltNrr;
              D01POS = w_UltNrr;
           EndIf;
           If D01POS = 0;
              D01POS = 1;
           EndIf;

           //Muestra la pantalla Subfile
           Write TITULOS;
           If w_NRR > 0;
              Ind_MuestraSFL = *On;   //SFLDSP
              Ind_PermiteAvP = *On;   //Habilita Page Down
           Else;
              Write REGVACIO;
           EndIf;
           Ind_MuestraCtl = *On;      //SFLDSPCTL

           Write REGTECLAS;
           ExFmt SFLCTL;
           Ind_MuestraSFL = *Off;     //SFLDSP
           Ind_MuestraCtl = *Off;     //SFLDSPCTL
           Ind_PermiteAvP = *Off;     //Page Down

           //Apaga indicadores de Mensajes del Subfile
           Ind_MsgFinSFL = *Off;
           Ind_MsgIniSFL = *Off;

           //Asigna ultima posición del cursor en la pantalla
           If DREGREL <> 0;
             D01POS = DREGREL;
           Else;
             D01POS = 1;
           EndIf;

           //Verifica Teclas de Función y Posicionamiento;
           Select;
           When Ind_TecSalir;
              Leave;
           When Ind_TecRePag;   //Retroceder página
              Ind_MsgIniSFL = *On;        //Msg: Inicio de la lista
           When Ind_TecAvPag;   //Avance de página
              If Ind_FinSFL = *Off;       //Si No es Fin del Subfile
                 Pr_LlenaPagina();
              Else;
                 Ind_MsgFinSFL = *On;        //Msg: Final de la lista
                 If DREGREL = 0;
                   D01POS = w_UltNrr;
                 EndIf;
              EndIf;
           When Ind_TecVolver;
             Clear POSID1;
             Clear POSID2;
             Clear POSID3;
              Pr_Posiciona(); //Modifica los Filtros y Ordenamiento del Cursor
              Pr_Prepare();
              Pr_LimpiaSFL();
              Pr_LlenaPagina();
           When Ind_TecCrear;   //Crear Registros
              Pr_Crear();
           When POSID1 <> hPOSID1 Or   //Posiciona
              POSID2 <> hPOSID2 Or
              POSID3 <> hPOSID3;
              Pr_Posiciona(); //Modifica los Filtros y Ordenamiento del Cursor
              Pr_Prepare();
              Pr_LimpiaSFL();
              Pr_LlenaPagina();
           Other;   //Enter
              If w_UltNrr > 0;
                Pr_Opciones();
                Clear POSID1;
                Clear POSID2;
                Clear POSID3;
                Clear hPOSID1;
                Clear hPOSID2;
                Clear hPOSID3;
              EndIf;
           EndSl;
        EndDo;
        // Termina programa
        Exec SQL Close CursorTabla;
        *InLr = *On;
      /End-Free

      * ========================================================================
      * Nombre Proc.: Pr_Prepare
      * Propósito...: Prepara SQL y Crea Cursor
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Prepare       B
      /Free
        w_StrSQL = %Trim(w_StrTabla)  + ' ' +
                   %Trim(w_StrFiltro) + ' ' +
                   %Trim(w_StrOrden)  + ' ' +
                   %Trim(w_StrOptimize);

        Exec SQL Close CursorTabla;
        Exec Sql Prepare SentSQL From :w_StrSQL;
        Exec Sql Declare CursorTabla Dynamic Scroll Cursor For SentSQL;

      /End-Free
     PPr_Prepare       E

      * ========================================================================
      * Nombre Proc.: Pr_LimpiaSFL
      * Propósito...: Limpia Subfile e Inicializa Cursor
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_LimpiaSFL     B
      /Free
        //Limpia Subfile
        w_NRR    = 0;
        w_UltNrr = 0;
        D01POS   = 1;
        Ind_FinSFL = *Off;    //Fin del Subfile

        Ind_LimpiaSFL = *On;
        Write SFLCTL;
        Ind_LimpiaSFL = *Off;

        //Inicializa Cursor
        Exec SQL Close CursorTabla;
        Exec SQL Open CursorTabla;
      /End-Free
     PPr_LimpiaSFL     E

      * ========================================================================
      * Nombre Proc.: Pr_LlenaPagina
      * Propósito...: Adiciona en el SubFile los registros de una página
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_LlenaPagina   B
      *
     D i               s              2s 0 Inz(0)
     D c_wRegXPag      C                   Const(10)
      /Free
        w_NRR = w_UltNrr;
        //Control Desbordamiento
        If w_NRR = 9999;
           Return;
        EndIf;

        For i = 1 to c_wRegXPag;
           Exec SQL Fetch CursorTabla Into :Ds_Tabla;
           If SQLCODE <> 0;  //Fin del Archivo
              Ind_FinSFL = *On;   //Fin del Subfile
              Leave;
           EndIf;

           //Escribe Registro en el SubFile
           Clear SFL;
           Pr_AsignaSFL(); //Asigna los campos del subfile
           w_NRR += 1;
           Write SFL;

           //Posiciona el cursor en la página a mostrar
           D01POS = w_UltNrr + 1;            //Pantalla a Mostrar

           //Control Desbordamiento del SubFile
           If w_NRR = 9999;
              Leave;
           EndIf;
        EndFor;
        w_UltNrr    = w_NRR;
        w_LLenarSfl = 'N';
      /End-Free
     PPr_LlenaPagina   E

      * ========================================================================
      * Nombre Proc.: Pr_AsignaSFL
      * Propósito...: Actualiza campos del Subfile con los del Archivo/Pantalla
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_AsignaSFL     B
      /Free
        SIDREG1  = SOLCOD;
        SIDREG2  = SOLCO1;
        SIDREG3  = SOLNUM;
        SIDREG4  = SOLFEC;
        SIDREG5  = SOLFE1;
        SIDREG6  = SOLVAL;

      /End-Free
     PPr_AsignaSFL     E

      * ========================================================================
      * Nombre Proc.: Pr_Opciones
      * Propósito...: Recorre Subfile procesando opciones digitadas por usuario
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Opciones      B
      /Free
        w_LLenarSfl = 'N'; //Controla llenar nuevamente el Sfl
        For w_NRR = 1 To w_UltNrr;
          Chain w_NRR SFL;
          If %Found();
            Select;
             When SOPC = '2';
               Pr_Modificar();
             When SOPC = '4';
               Pr_Eliminar();
             When SOPC = '5';
               Pr_Consultar();
            EndSl;

            If SOPC <> *Blanks;
              //Asigna Ultimo Registro procesado
              D01POS = w_NRR;
              //Actualiza el registro del subfile
              SOPC = *Blanks;
              Update SFL;
            EndIf;
          EndIf;
        EndFor;
        Ind_TecSalir = *Off;
      /End-Free
     PPr_Opciones      E

      * ========================================================================
      * Nombre Proc.: Fn_Centrar
      * Propósito...: Devuelve un texto Centrado a 50 caracteres
      * Parámetros..: p_Texto = Texto recibido para ser centrado
      * ------------------------------------------------------------------------
     PFn_Centrar       B
     DFn_Centrar       Pi            50a
     D  p_Texto                      50a   Const
      *
     D w_Long          s              2s 0
     D w_PosIni        s              2s 0
     D w_Tit           s             50a
      /Free
        w_Long   = %Len(%Trim(p_Texto));
        w_PosIni = (50 - w_Long) / 2;
        %SubSt(w_Tit: w_PosIni) = %Trim(p_Texto);
        Return w_Tit;
      /End-Free
     PFn_Centrar       E

      * ========================================================================
      * Nombre Proc.: Pr_Posiciona
      * Propósito...: Modifica los Filtros y Ordenamiento del Cursor
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Posiciona     B
      /Free
        //Filtro
        If POSID1 = *Blanks And POSID2 = *Blanks And POSID3 = *Zeros;
          w_StrFiltro = *Blanks;
        Else;
          w_StrFiltro = 'WHERE 1 = 1 ';
          w_StrOrden  = 'ORDER BY SOLCOD';
        EndIf;
        //Se posiciona por el código del fondo
        If POSID1 <> *Blanks;
          w_StrFiltro = %Trim(w_StrFiltro) + ' AND SOLCOD >= '
                        + C_Com + POSID1 + C_Com;
          POSID1 = *Blanks;
        EndIf;
        //Se posiciona por el código de la oficina
        If POSID2 <> *Blanks;
          w_StrFiltro = %Trim(w_StrFiltro) + ' AND SOLCO1 >= '
                        + C_Com + POSID2 + C_Com;
          w_StrOrden  =  %Trim(w_StrOrden) +  ', SOLCO1';
          POSID2 = *Blanks;
        EndIf;
        //Se posiciona por el código de la oficina
        If POSID3 <> *Zeros;
          w_StrFiltro = %Trim(w_StrFiltro) + ' AND SOLNUM >= '
                        + C_Com + %Char(POSID3) + C_Com;
          w_StrOrden  =  %Trim(w_StrOrden) +  ', SOLNUM';
          POSID3 = *Zeros;
        EndIf;
        //Iguala variables ocultas
        hPOSID1 = POSID1;
        hPOSID2 = POSID2;
        hPOSID3 = POSID3;
      /End-Free
     PPr_Posiciona     E

      * ========================================================================
      * Nombre Proc.: Pr_Crear
      * Propósito...: Crea un nuevo registro en la Tabla
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Crear         B
      *
     D Ind_ProteTodo   s               N   Inz(*OFF)
      /Free
        Ind_MsgAgrega = *Off;
        //Limpia los campos para mostrar en pantalla
        Clear Ds_Tabla;
        DOPCION        = 'Agregar';
        FTECLA1        = 'Intro=';
        FDES1          = 'Continuar';
        //Muestra la pantalla
        DoW '1';
          Ind_TecConfirm = *Off;
          Ind_ProteClave = Ind_ProteTodo;
          Ind_ProteCampo = Ind_ProteTodo;
          Ind_PermitConf = *Off;
          Ind_PermitF3   = *Off;
          Write TITULOS;
          Write REGTECLAD1;
          Write REGDATOS;
          ExFmt REGDATOS;
          //Se valida el ingreso de los demás datos
          If Ind_TecSalir;
            Leave;
          ElseIf Fn_Valida() ;
             Iter;
          Else;
            DoW '1';
              DOPCION        = 'Agregar';
              FTECLA        = 'F10=';
              FDES          = 'Confirmar';

              Ind_TecConfirm = *Off;
              Ind_ProteClave = Ind_ProteTodo;
              Ind_ProteCampo = Ind_ProteTodo;
              Ind_PermitConf = *On;
              Ind_PermitF3   = *On;
              Write TITULOS;
              Write REGTECLAD;
              Write REGDATOS1;
              ExFmt REGDATOS1;

              If Ind_F3;
                Return;
              ElseIf Ind_TecSalir;
                Leave;
              ElseIf Ind_TecConfirm;
               //Se asignan los campos de auditoría y se escribe el registro
              //CFUSUA   = Ds_As400.Usr;
              //CFFECHA  = %Char(%Date(): *Iso0);
              //CFHORA   = %Char(%Time(): *Iso0);
                Write SOLREG;
                Ind_MsgAgrega = *On;

                //Se escribe en el log de auditoria
                w_Opera    = 'Agregar';
                w_Libreria = Libreria;
                w_RegAnt   = *Blanks;
                w_RegDesp  = Ds_Tabla.SOLCOD             +
                             Ds_Tabla.SOLCO1             +
                             %Trim(%editc(Ds_Tabla.SOLNUM:'X')) +
                             Ds_Tabla.SOLFEC             +
                             Ds_Tabla.SOLFE1             +
                             Ds_Tabla.SOLFE2             +
                             %Trim(%editc(Ds_Tabla.SOLVAL:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPOR:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPO1:'X')) +
                             Ds_Tabla.SOLDIS             +
                             Ds_Tabla.SOLOBS             +
                             Ds_Tabla.SOLAUT             +
                             Ds_Tabla.SOLFOR             +
                             Ds_Tabla.SOLOFI             +
                             %Trim(%editc(Ds_Tabla.SOLNU1:'X')) +
                             Ds_Tabla.SOLEN1             +
                             Ds_Tabla.SOLCU1             +
                             Ds_Tabla.SOLUSU             +
                             Ds_Tabla.SOLCON             +
                             Ds_Tabla.SOLFE3            +
                             %Trim(%editc(Ds_Tabla.SOLCOM:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLDIA:'X')) +
                             Ds_Tabla.SOLFE4             +
                             Ds_Tabla.SOLFO1             +
                             Ds_Tabla.SOLOB1             +
                             Ds_Tabla.SOLOB2             +
                             %Trim(%editc(Ds_Tabla.SOLC08:'X')) +
                             Ds_Tabla.SOLIND             +
                             %Trim(%editc(Ds_Tabla.SOLSE1:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLEFE:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLCHE:'X')) +
                             Ds_Tabla.SOLCOB             +
                             Ds_Tabla.SOLFE9             +
                             Ds_Tabla.SOLTI1             +
                             %Trim(%editc(Ds_Tabla.SOLIDE:'X')) +
                             Ds_Tabla.SOLCO2             +
                             Ds_Tabla.SOLENT             +
                             Ds_Tabla.SOLCUE             +
                             Ds_Tabla.SOLCO3             +
                             Ds_Tabla.SOLCO4             +
                             Ds_Tabla.SOLCO8             +
                             %Trim(%editc(Ds_Tabla.SOLCO9:'X')) ;

              Pr_LogDFU(w_RegAnt:w_RegDesp:w_Opera:w_Libreria:w_Archivo);
                //Se llena nuevamente el subfile
                w_LLenarSfl = 'S';
                Return;
              EndIf;
            EndDo;
          EndIf;
        EndDo;
      /End-Free
     PPr_Crear         E

      * ========================================================================
      * Nombre Proc.: Pr_Modificar
      * Propósito...: Modifica el registro seleccionado
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Modificar     B
      /Free

        Ind_MsgModifi = *Off;
        //Obtiene el registro seleccionado
        Chain(n) (SIDREG1:SIDREG2:SIDREG3) SOLARC;
        If Not %Found(SOLARC);
          Ind_MsgNoFound = *On;
          Clear Ds_Tabla;
          SOLCOD = SIDREG1;
          SOLCO1 = SIDREG2;
          SOLNUM = SIDREG3;
          Ind_ProteCampo = *On;
        Else;
          Ds_TablaQ = Ds_Tabla; //Guarda los valores del Registro
          Ind_ProteCampo = *Off;
        EndIf;

        Ind_ProteClave = *On;
        Ind_PermitConf = *Off;
        DOPCION        = 'Modificar';
        FTECLA1        = 'Intro=';
        FDES1          = 'Continuar';
        //Muestra la pantalla
        DoW '1';
           Ind_PermitConf = *Off;
           Ind_PermitF3   = *Off;
           Write TITULOS;
           Write REGTECLAD1;
           Write REGDATOS;
           ExFmt REGDATOS;

           //Se valida el ingreso de los demás datos
           If Not %Found(SOLARC) or Ind_TecSalir;
             Leave;
           Else;
             DoW '1';
               FTECLA         = 'F10=';
               FDES           = 'Confirmar';

               Ind_TecConfirm = *Off;
               Ind_PermitConf = *On;
               Ind_PermitF3   = *On;
               Write TITULOS;
               Write REGTECLAD;
               Write REGDATOS1;
               ExFmt REGDATOS1;

               If Ind_F3;
                 Return;
               ElseIf Ind_TecSalir;
                 Leave;
               ElseIf Ind_TecConfirm;
                 Ds_TablaQ = Ds_Tabla; //Guarda los valores de la pantalla
                 Chain (SIDREG1:SIDREG2:SIDREG3) SOLARC;
                 If Not %Found(SOLARC);
                   Return;
                 Else;
                   w_RegAnt  =  Ds_Tabla.SOLCOD             +
                             Ds_Tabla.SOLCO1             +
                             %Trim(%editc(Ds_Tabla.SOLNUM:'X')) +
                             Ds_Tabla.SOLFEC             +
                             Ds_Tabla.SOLFE1             +
                             Ds_Tabla.SOLFE2             +
                             %Trim(%editc(Ds_Tabla.SOLVAL:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPOR:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPO1:'X')) +
                             Ds_Tabla.SOLDIS             +
                             Ds_Tabla.SOLOBS             +
                             Ds_Tabla.SOLAUT             +
                             Ds_Tabla.SOLFOR             +
                             Ds_Tabla.SOLOFI             +
                             %Trim(%editc(Ds_Tabla.SOLNU1:'X')) +
                             Ds_Tabla.SOLEN1             +
                             Ds_Tabla.SOLCU1             +
                             Ds_Tabla.SOLUSU             +
                             Ds_Tabla.SOLCON             +
                             Ds_Tabla.SOLFE3            +
                             %Trim(%editc(Ds_Tabla.SOLCOM:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLDIA:'X')) +
                             Ds_Tabla.SOLFE4             +
                             Ds_Tabla.SOLFO1             +
                             Ds_Tabla.SOLOB1             +
                             Ds_Tabla.SOLOB2             +
                             %Trim(%editc(Ds_Tabla.SOLC08:'X')) +
                             Ds_Tabla.SOLIND             +
                             %Trim(%editc(Ds_Tabla.SOLSE1:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLEFE:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLCHE:'X')) +
                             Ds_Tabla.SOLCOB             +
                             Ds_Tabla.SOLFE9             +
                             Ds_Tabla.SOLTI1             +
                             %Trim(%editc(Ds_Tabla.SOLIDE:'X')) +
                             Ds_Tabla.SOLCO2             +
                             Ds_Tabla.SOLENT             +
                             Ds_Tabla.SOLCUE             +
                             Ds_Tabla.SOLCO3             +
                             Ds_Tabla.SOLCO4             +
                             Ds_Tabla.SOLCO8             +
                             %Trim(%editc(Ds_Tabla.SOLCO9:'X')) ;
                   //CFUSUA   = Ds_As400.Usr;
                   //CFFECHA  = %Char(%Date(): *Iso0);
                   //CFHORA   = %Char(%Time(): *Iso0);
                   Ds_Tabla = Ds_TablaQ; //Asigna los valores de la pantalla
                   Update SOLREG;
                   Ind_MsgModifi = *On;

                   //Se escribe en el log de auditoria
                    w_Opera    = 'Actualizar';
                    w_Libreria = Libreria;
                    w_RegDesp  =  Ds_Tabla.SOLCOD             +
                             Ds_Tabla.SOLCO1             +
                             %Trim(%editc(Ds_Tabla.SOLNUM:'X')) +
                             Ds_Tabla.SOLFEC             +
                             Ds_Tabla.SOLFE1             +
                             Ds_Tabla.SOLFE2             +
                             %Trim(%editc(Ds_Tabla.SOLVAL:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPOR:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPO1:'X')) +
                             Ds_Tabla.SOLDIS             +
                             Ds_Tabla.SOLOBS             +
                             Ds_Tabla.SOLAUT             +
                             Ds_Tabla.SOLFOR             +
                             Ds_Tabla.SOLOFI             +
                             %Trim(%editc(Ds_Tabla.SOLNU1:'X')) +
                             Ds_Tabla.SOLEN1             +
                             Ds_Tabla.SOLCU1             +
                             Ds_Tabla.SOLUSU             +
                             Ds_Tabla.SOLCON             +
                             Ds_Tabla.SOLFE3            +
                             %Trim(%editc(Ds_Tabla.SOLCOM:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLDIA:'X')) +
                             Ds_Tabla.SOLFE4             +
                             Ds_Tabla.SOLFO1             +
                             Ds_Tabla.SOLOB1             +
                             Ds_Tabla.SOLOB2             +
                             %Trim(%editc(Ds_Tabla.SOLC08:'X')) +
                             Ds_Tabla.SOLIND             +
                             %Trim(%editc(Ds_Tabla.SOLSE1:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLEFE:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLCHE:'X')) +
                             Ds_Tabla.SOLCOB             +
                             Ds_Tabla.SOLFE9             +
                             Ds_Tabla.SOLTI1             +
                             %Trim(%editc(Ds_Tabla.SOLIDE:'X')) +
                             Ds_Tabla.SOLCO2             +
                             Ds_Tabla.SOLENT             +
                             Ds_Tabla.SOLCUE             +
                             Ds_Tabla.SOLCO3             +
                             Ds_Tabla.SOLCO4             +
                             Ds_Tabla.SOLCO8             +
                             %Trim(%editc(Ds_Tabla.SOLCO9:'X')) ;

                 Pr_LogDFU(w_RegAnt:w_RegDesp:w_Opera:w_Libreria:w_Archivo);

                   //Actualiza los campos del subfile
                   Pr_AsignaSFL();
                   Return;
                 EndIf;
               EndIf;
             EndDo;
           EndIf;
        EndDo;
      /End-Free
     PPr_Modificar     E

      * ========================================================================
      * Nombre Proc.: Pr_Eliminar
      * Propósito...: Eliminar el registro seleccionado
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Eliminar      B
      /Free
        Ind_MsgElimin = *Off;
        //Obtiene el registro seleccionado
        Chain(n) (SIDREG1:SIDREG2:SIDREG3) SOLARC;
        If Not %Found(SOLARC);
          Ind_MsgNoFound = *On;
          Clear Ds_Tabla;
          SOLCOD = SIDREG1;
          SOLCO1 = SIDREG2;
          SOLNUM = SIDREG3;
          Ind_PermitElim = *Off;
        Else;
          Ind_PermitElim = *On;
        EndIf;

        Ind_ProteCampo = *On;
        Ind_ProteClave = *On;
        DOPCION        = 'Eliminar';
        FTECLA1        = ' F23=';
        FDES1          = 'Eliminar';

        //Muestra la pantalla
        DoW '1';
           Write TITULOS;
           Write REGTECLAD1;
           Write REGDATOS;
           ExFmt REGDATOS;
           //Se valida el ingreso de los demás datos
           If Not %Found(SOLARC) or Ind_TecSalir;
             Leave;
           EndIf;
           //Si se presiono la tecla eliminar
           If Ind_TecElimina;
             Chain (SIDREG1:SIDREG2:SIDREG3) SOLARC;
             If Not %Found(SOLARC);
                Leave;
             Else;
                Delete SOLREG;
                Ind_MsgElimin = *On;

                  //Se escribe en el log de auditoria
                 w_Opera    = 'Eliminar';
                 w_Libreria = Libreria;
                 w_RegDesp  = *Blanks;
                 w_RegAnt   =  Ds_Tabla.SOLCOD             +
                             Ds_Tabla.SOLCO1             +
                             %Trim(%editc(Ds_Tabla.SOLNUM:'X')) +
                             Ds_Tabla.SOLFEC             +
                             Ds_Tabla.SOLFE1             +
                             Ds_Tabla.SOLFE2             +
                             %Trim(%editc(Ds_Tabla.SOLVAL:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPOR:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLPO1:'X')) +
                             Ds_Tabla.SOLDIS             +
                             Ds_Tabla.SOLOBS             +
                             Ds_Tabla.SOLAUT             +
                             Ds_Tabla.SOLFOR             +
                             Ds_Tabla.SOLOFI             +
                             %Trim(%editc(Ds_Tabla.SOLNU1:'X')) +
                             Ds_Tabla.SOLEN1             +
                             Ds_Tabla.SOLCU1             +
                             Ds_Tabla.SOLUSU             +
                             Ds_Tabla.SOLCON             +
                             Ds_Tabla.SOLFE3            +
                             %Trim(%editc(Ds_Tabla.SOLCOM:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLDIA:'X')) +
                             Ds_Tabla.SOLFE4             +
                             Ds_Tabla.SOLFO1             +
                             Ds_Tabla.SOLOB1             +
                             Ds_Tabla.SOLOB2             +
                             %Trim(%editc(Ds_Tabla.SOLC08:'X')) +
                             Ds_Tabla.SOLIND             +
                             %Trim(%editc(Ds_Tabla.SOLSE1:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLEFE:'X')) +
                             %Trim(%editc(Ds_Tabla.SOLCHE:'X')) +
                             Ds_Tabla.SOLCOB             +
                             Ds_Tabla.SOLFE9             +
                             Ds_Tabla.SOLTI1             +
                             %Trim(%editc(Ds_Tabla.SOLIDE:'X')) +
                             Ds_Tabla.SOLCO2             +
                             Ds_Tabla.SOLENT             +
                             Ds_Tabla.SOLCUE             +
                             Ds_Tabla.SOLCO3             +
                             Ds_Tabla.SOLCO4             +
                             Ds_Tabla.SOLCO8             +
                             %Trim(%editc(Ds_Tabla.SOLCO9:'X')) ;

                 Pr_LogDFU(w_RegAnt:w_RegDesp:w_Opera:w_Libreria:w_Archivo);

                 //Si elimina registro se requiere actualizar Subfile
                 w_LLenarSfl = 'S';
                Leave;
             EndIf;
           EndIf;
        EndDo;
      /End-Free
     PPr_Eliminar      E

      * ========================================================================
      * Nombre Proc.: Pr_Consultar
      * Propósito...: Consulta el registro seleccionado
      * Parámetros..:
      * ------------------------------------------------------------------------
     PPr_Consultar     B
      /Free
        //Obtiene el registro seleccionado
        Chain(n) (SIDREG1:SIDREG2:SIDREG3) SOLARC;
        If Not %Found(SOLARC);
          Ind_MsgNoFound = *On;
          Clear Ds_Tabla;
          SOLCOD = SIDREG1;
          SOLCO1 = SIDREG2;
          SOLNUM = SIDREG3;
        EndIf;

        Ind_ProteClave = *On;
        Ind_ProteCampo = *On;
        Ind_PermitConf = *Off;
        DOPCION        = 'Consultar';
        FTECLA1        = 'Intro=';
        FDES1          = 'Continuar';
        //Muestra la pantalla
        DoW '1';
           Ind_PermitF3   = *Off;
           Write TITULOS;
           Write REGTECLAD1;
           Write REGDATOS;
           ExFmt REGDATOS;
           If Not %Found(SOLARC) or Ind_TecSalir;
             Leave;
           Else;
             //Se realiza la consulta de los demás datos
             DoW '1';
                FTECLA         = ' ';
                FDES           = ' ';
                Ind_PermitF3   = *On;
                Write TITULOS;
                Write REGTECLAD;
                Write REGDATOS1;
                ExFmt REGDATOS1;
                If Ind_F3;
                  Return;
                ElseIf Ind_TecSalir;
                  Leave;
                EndIf;
             EndDo;
           EndIf;
        EndDo;
      /End-Free
     PPr_Consultar     E

      * ========================================================================
      * Nombre Proc.: Fn_Valida
      * Propósito...: Valida campos de la Pantalla y devuelve 'OK' o 'ER'
      * Parámetros..:
      * ------------------------------------------------------------------------
     PFn_Valida        B
     DFn_Valida        Pi              N
      *
      /Free

        Ind_ErrFondo = *Off;
        Ind_ErrOficina = *Off;
        Ind_ErrSolici = *Off;
        Ind_Errexiste = *Off;
        //Validaciones solo para Ingreso
        If Ind_TecCrear;
          If SOLCOD = *Blanks;
            Ind_ErrFondo = *On;
            Return *On;
          ElseIf SOLCO1 = *Blanks;
            Ind_ErrOficina = *On;
            Return *On;
           ElseIf SOLNUM = *Zeros;
            Ind_ErrSolici = *On;
            Return *On;
          Else;
           Setll (SOLCOD:SOLCO1:SOLNUM) SOLARC;
            if (%equal(SOLARC));
               Ind_Errexiste = *On;
               Return *On;
            Else;
               Return *Off;
            EndIf;
          EndIf;
        EndIf;

        Return *Off;
      /End-Free
     PFn_Valida        E
