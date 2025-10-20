/* %charResize updates character columns in the specified data set if */
/* the defined length is larger than the length of the longest value in the variable */

%macro CharResize(lib=work, data=, outLib=work, out=);

    %local summary len_stmt;

    /* Uses the max_char_lengths macro to generate a data set named all_char_len of the character variables and lengths */
    %let summary = all_char_len;
    %charCheck(lib=&lib, data=&data, out=&summary);

    /* Creates a data set named charvar_to_shrink of the variables that can be reduced in length */
    proc sql noprint;
        create table charvar_to_shrink as
        select Variable, DefinedLength, MaxLength
        from &summary
        where MaxLength < DefinedLength and not missing(MaxLength);
    quit;

    /* Uses charvar_to_shrink to create a list of variable names, the $ and the maxlength to use as the new length */
    proc sql noprint;
        select catx(' ', Variable, cats('$', MaxLength))
        into :len_stmt separated by " "
        from charvar_to_shrink;
    quit;
    %put &=len_stmt;

    /* If the out= parameter is not specified, the output dataset will be the name of the original data set with the _shrunk suffix */
    %if %superq(out)= %then %let out=&data._shrunk;

    /* If the length statement is not missing, then create a copy of the original data set with specified lengths */
    data &outLib..&out;
        %if %superq(len_stmt)^= %then %do;
            length &len_stmt;
        %end;
        set &lib..&data;
    run;

%mend charResize;

/* Example usage */
/* Provide the library name, data set name, library to write the output data set to, and output data set name */

/* Example with SASHELP.COMPANY */
%charResize(lib=sashelp, data=company, outLib=work, out=company_new);

/* Example with SASHELP.CARS */
%charResize(lib=sashelp, data=cars, outLib=work, out=cars_new);






