/* %charCheck creates a data set of all character variables in a specified data set along with */
/* their defined length and the length of the longest value in the variable */

%macro charCheck(lib=work, data=, out=char_lengths);

    %local dsid nvars i varname vartype varlen rc;

    /* Open the dataset in input mode */
    /* If the data set exists and opens successfully, open returns a positive integer like 1, 2, 3... */
    %let dsid = %sysfunc(open(&lib..&data,i));
    /*  So if the data set opens successfully, &dsid>0, the then do block executes */
    %if &dsid %then %do;
		
		/* Queries the number of variables in the data set referred to by dsid */
        %let nvars = %sysfunc(attrn(&dsid,nvars));

        /* Create a dataset to store results */
        data &out;
            length Variable $32. DefinedLength MaxLength 8.;
            stop;
        run;

        /* Loop over variables and creates &i */
        %do i = 1 %to &nvars;
        	/* Stores whether the current variable is N (numeric) or C (character) */
            %let vartype = %sysfunc(vartype(&dsid,&i));
            /* If the value of vartype is C (character) then do... */
            %if &vartype = C %then %do;
            	/* Stores the name of the i-th variable */
                %let varname = %sysfunc(varname(&dsid,&i));
                /* Stores the defined length of the i-th variable */
                %let varlen  = %sysfunc(varlen(&dsid,&i));

                proc sql noprint;
                	/* Appends a new row to the data set, each character variable will be it's own row */
                    insert into &out
                    	   /* Puts the variable name into a column named Variable */
                    select "&varname" as Variable,
                    	   /* Puts the variables defined length into a column named DefinedLength */
                           &varlen as DefinedLength,
                           /* Looks in all rows of the column to put the longest value into a column named MaxLength */
                           /* LengthN returns the length of a character string, excluding trailing blanks, returns 0 if the value of string is blank */
                           /* Max finds the longest observed value */
                           max(lengthn(&varname)) as MaxLength
                    from &lib..&data;
                quit;
            %end;
        %end;
		
		/* Closes the data set */
        %let rc = %sysfunc(close(&dsid));
        /* Verifies the data set was closed successfully (0= success, nonzero= error) */
        %put Dataset close return code = &rc;

    %end;
    
    /* If the data set did not open successfully, print the following error */
    %else %do;
        %put ERROR: Dataset &lib..&data not found.;
    %end;

%mend charCheck;


/* Example usage */
/* Provide the library name, data set name, and name of the output data set to create */

/* Example with SASHELP.COMPANY */
%charCheck(lib=sashelp, data=company, out=char_lengths);
/* Example with SASHELP.CARS */
%charCheck(lib=sashelp, data=cars, out=char_lengths);










