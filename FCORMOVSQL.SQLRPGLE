      *------------------------------------------------------------------------
      * PROGRAMA...: FCORMOVSQL
      * AUTOR......:
      * FECHA......: 2019-10-25
      * DESCRIPCION: Actualización de Datos
      *------------------------------------------------------------------------
      *COMPILACION:
      *------------------------------------------------------------------------
       Ctl-Opt DftActGrp(*No);
       Ctl-Opt ActGrp   (*Caller);
       Ctl-Opt Copyright('Copyright © 2019 GRUPO BANCOLOMBIA');

     **Free
      * Variables
       dcl-s w_strsql VARCHAR(1000);
      * -- Parámetros ---------------------------------------------------------

      *  Prototipo

       Dcl-pr Parametros ExtPgm('FCORMOVSQL');
       End-pr;

      *  Interfaz

       dcl-pi Parametros;
       end-pi;


      * -- Bloque principal ---------------------------------------------------

        Exec sql Declare Cursor1 Cursor for
         Select SentSQl from XXPSJCPL.FCOFFSQL;
        Exec sql Open Cursor1;
        dow 1 = 1;
        Exec sql
          fetch from Cursor1 into :w_strsql ;
          if sqlcode = 0;
           Exec SQL Prepare Consulta From :w_strsql;
           Exec SqL Execute Consulta;
           if sqlcode = 0;
           endif;
          else;
            leave;
          endif;
        Enddo;
        Exec sql Close Cursor1;
        *Inlr = *On; 