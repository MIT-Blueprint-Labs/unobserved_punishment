* Description: Master do file for "Unobserved Punishment Supports Cooperation";
* Author: Parag Pathak;
* Last updated: 1/11/09;

* Set path;
%let homelib=A:/unobserved-punishment/vnorman/;

options linesize=100;

****************************************************************************;
/***************				1. Read in data    			 ***************/
****************************************************************************;

*** Read in data from session T1 ***;

* Stage 1 (public good contribution game) data;
filename inft1 "&homelib/raw_data/attend042707/data_main.TXT";

data sest1;
        infile inft1 dlm = "," firstobs = 2 dsd missover;
        input period subject group profit totalprofit participate total_deduct
              total_first_inc total_cost contrib timeOK1 pcontrib sumC profit1O profit1G
              timeOKP timeOK2 cost timeOK3 received reduction profit2 temp_profit
              timeOK4 totalprofitend;
        avgC = sumC / 4;
        drop timeOK1 timeOKP timeOK2 temp_profit timeOK3 timeOK4 total_first_inc;

* Stage 2 (punishment phase) data;
filename inft1b "&homelib/raw_data/attend042707/punish_main.TXT";

data punish;
        infile inft1b dlm = "," firstobs = 2 dsd missover;
        input period subject target group otherc otherp points;

proc sort data = punish;
        by period subject;

data punish;
        set punish;
        by period subject;
        retain opp1 opp2 opp3 pun1 pun2 pun3 con1 con2 con3;
        if first.subject then do;
                opp1 = target;
                opp2 = .;
                opp3 = .;
                pun1 = points;
                pun2 = .;
                pun3 = .;
                con1 = otherc;
                con2 = .;
                con3 = .;
        end; else if last.subject then do;
                opp3 = target;
                pun3 = points;
                con3 = otherc;
        end; else do;
                opp2 = target;
                pun2 = points;
                con2 = otherc;
        end;
        if last.subject;
        drop group target otherc points;
        totalp = pun1 + pun2 + pun3;
        totalp = -1 * totalp;

* Merge data sets;
data sest1;
        merge sest1 punish;
        by period subject;
	session = "T1";

*** Read in data from session T2 ***;

* Stage 1 (public good contribution game) data;
filename inft2 "&homelib/raw_data/attend102407/data_main.TXT";

data sest2;
		infile inft2 dlm = "," firstobs = 2 dsd missover;
		input period subject group profit totalprofit participate total_deduct
			  total_first_inc total_cost contrib pcontrib sumC n profit1O profit1G
		      profit1 cost received reduction profit2 temp_profit punish10 $ punish10u $
			  punish10d $ totalprofitend punish20 $ punish20u $ punish20d $;
		avgC = sumC / 4;
		drop temp_profit total_first_inc;
		if punish10 = "-" then pun10 = .; else pun10 = 1.0*punish10;
		if punish10u = "-" then pun10u = .; else pun10u = 1.0*punish10u;
		if punish10d = "-" then pun10d = .; else pun10d = 1.0*punish10d;
		if punish20 = "-" then pun20 = .; else pun20 = 1.0*punish20;
		if punish20u = "-" then pun20u = .; else pun20u = 1.0*punish20u;
		if punish20d = "-" then pun20d = .; else pun20d = 1.0*punish20d;
		drop punish10 punish10u punish10d punish20 punish20u punish20d;

* Stage 2 (punishment phase) data;
filename inft2b "&homelib/raw_data/attend102407/punish_main.TXT";

data punish;
        infile inft2b dlm = "," firstobs=2 dsd missover;
        input period subject target group otherc otherp points;

proc sort data = punish;
        by period subject;

data punish;
        set punish;
        by period subject;
        retain opp1 opp2 opp3 pun1 pun2 pun3 con1 con2 con3;
        if first.subject then do;
                opp1 = target;
                opp2 = .;
                opp3 = .;
                pun1 = points;
                pun2 = .;
                pun3 = .;
                con1 = otherc;
                con2 = .;
                con3 = .;
        end; else if last.subject then do;
                opp3 = target;
                pun3 = points;
                con3 = otherc;
        end; else do;
                opp2 = target;
                pun2 = points;
                con2 = otherc;
        end;
        if last.subject;
        drop group target otherc points;
		totalp = pun1 + pun2 + pun3;
		totalp = -1 * totalp;

proc sort data = sest2;
        by period subject;

* Merge data sets;
data sest2;
        merge sest2 punish;
        by period subject;
	session = "T2";

*** Read in data from session T3 ***;

* Stage 1 (public good contribution game) data;
filename inft3 "&homelib/raw_data/attend042808/data_main.TXT";

data sest3;
        infile inft3 dlm = "," firstobs = 2 dsd missover;
        input period subject group profit totalprofit participate total_deduct
              total_first_inc total_cost contrib pcontrib sumC n profit1O profit1G
              profit1 cost received reduction profit2;
        avgC = sumC / 4;
        drop total_first_inc n;

* Stage 2 (punishment phase) data;
filename inft3b "&homelib/raw_data/attend042808/punish_data.TXT";

data punish;
        infile inft3b dlm = "," firstobs = 2 dsd missover;
        input period subject target group otherc otherp points;

proc sort data = punish;
        by period subject;

data punish;
        set punish;
        by period subject;
        retain opp1 opp2 opp3 pun1 pun2 pun3 con1 con2 con3;
        if first.subject then do;
                opp1 = target;
                opp2 = .;
                opp3 = .;
                pun1 = points;
                pun2 = .;
                pun3 = .;
                con1 = otherc;
                con2 = .;
                con3 = .;
        end; else if last.subject then do;
                opp3 = target;
                pun3 = points;
                con3 = otherc;
        end; else do;
                opp2 = target;
                pun2 = points;
                con2 = otherc;
        end;
        if last.subject;
        drop group target otherc points;
        totalp = pun1 + pun2 + pun3;
        totalp = -1 * totalp;

proc sort data = sest3;
        by period subject;

* Merge data sets;
data sest3;
        merge sest3 punish;
        by period subject;
	session = "T3";

*** Read in data from session T4 ***;

* Stage 1 (public good contribution game) data;
filename inft4 "&homelib/raw_data/attend121008/data_main.TXT";

data sest4;
        infile inft4 dlm = "," firstobs = 2 dsd missover;
        input period subject group profit totalprofit participate total_deduct
              total_first_inc total_cost contrib pcontrib sumC n profit1O profit1G
              profit1 cost received reduction profit2;
        avgC = sumC / 4;
        drop total_first_inc n;

* Stage 2 (punishment phase) data;
filename inft4b "&homelib/raw_data/attend121008/punish_data.TXT";

data punish;
        infile inft4b dlm = "," firstobs = 2 dsd missover;
        input period subject target group otherc otherp points;

proc sort data = punish;
        by period subject;

data punish;
        set punish;
        by period subject;
        retain opp1 opp2 opp3 pun1 pun2 pun3 con1 con2 con3;
        if first.subject then do;
                opp1 = target;
                opp2 = .;
                opp3 = .;
                pun1 = points;
                pun2 = .;
                pun3 = .;
                con1 = otherc;
                con2 = .;
                con3 = .;
        end; else if last.subject then do;
                opp3 = target;
                pun3 = points;
                con3 = otherc;
        end; else do;
                opp2 = target;
                pun2 = points;
                con2 = otherc;
        end;
        if last.subject;
        drop group target otherc points;
        totalp = pun1 + pun2 + pun3;
        totalp = -1 * totalp;

proc sort data = sest4;
        by period subject;

* Merge data sets;
data sest4;
        merge sest4 punish;
        by period subject;
	session = "T4";

*** Read in data from session C1 ***;

* Stage 1 (public good contribution game) data;
filename infb1 "&homelib/raw_data/base042407/042407data.TXT";

data base;
        infile infb1 dlm = "," firstobs = 2 dsd missover;
        input period subject group profit totalprofit contrib time
        	  sumC profit1own profit1grp profit1 cost received
        	  reduction profit2;
        avgC = sumC / 4;

proc sort data = base;
        by period subject;

* Stage 2 (punishment phase) data;
filename infb2 "&homelib/raw_data/base042407/042407data2.TXT";

data punish;
        infile infb2 dlm = "," firstobs = 2 dsd missover;
        input period subject target group otherc points;

proc sort data = punish;
        by period subject;

data punish;
        set punish;
        by period subject;
        retain opp1 opp2 opp3 pun1 pun2 pun3 con1 con2 con3;
        if first.subject then do;
                opp1 = target;
                opp2 = .;
                opp3 = .;
                pun1 = points;
                pun2 = .;
                pun3 = .;
                con1 = otherc;
                con2 = .;
                con3 = .;
        end; else if last.subject then do;
                opp3 = target;
                pun3 = points;
                con3 = otherc;
        end; else do;
                opp2 = target;
                pun2 = points;
                con2 = otherc;
        end;
        if last.subject;
        drop group target otherc points;
        totalp = -1 * (pun1 + pun2 + pun3);

proc sort data = punish;
        by period subject;

* Merge data sets;
data base;
        merge base punish;
        by period subject;
	session = "C1";

*** Read in data from session C2 ***;

* Stage 1 (public good contribution game) data;
filename infb21 "&homelib/raw_data/base121008/121008data.TXT";

data base2;
        infile infb21 dlm = "," firstobs = 2 dsd missover;
        input period subject group profit totalprofit contrib
        	  time sumC profit1own profit1grp profit1 cost
        	  received reduction profit2;
        avgC = sumC / 4;

proc sort data = base2;
        by period subject;

* Stage 2 (punishment phase) data;
filename infb22 "&homelib/raw_data/base121008/121008data2.TXT";

data punish;
        infile infb22 dlm = "," firstobs = 2 dsd missover;
        input period subject target group otherc points;

proc sort data = punish;
        by period subject;

data punish;
        set punish;
        by period subject;
        retain opp1 opp2 opp3 pun1 pun2 pun3 con1 con2 con3;
        if first.subject then do;
                opp1 = target;
                opp2 = .;
                opp3 = .;
                pun1 = points;
                pun2 = .;
                pun3 = .;
                con1 = otherc;
                con2 = .;
                con3 = .;
        end; else if last.subject then do;
                opp3 = target;
                pun3 = points;
                con3 = otherc;
        end; else do;
                opp2 = target;
                pun2 = points;
                con2 = otherc;
        end;
        if last.subject;
        drop group target otherc points;
        totalp = -1 * (pun1 + pun2 + pun3);

proc sort data = punish;
        by period subject;

* Merge data sets;
data base2;
        merge base2 punish;
        by period subject;
	session = "C2";

****************************************************************************;
/***************	    2. Prepare data for analysis  	   	 ***************/
****************************************************************************;

data jumbo;
		set base base2 sest1 sest2 sest3 sest4;
		if session = "C1" or session = "C2" then base = 1; else base = 0;

		punish = 0;
		if pun1 ~= 0 then punish = punish + 1;
		if pun2 ~= 0 then punish = punish + 1;
		if pun3 ~= 0 then punish = punish + 1;
		if punish > 0 then you_punished = 1; else you_punished = 0;
		if punish = 0 then you_not_punished = 1; else you_not_punished = 0;
		if received ~= 0 then got = 1; else got = 0;
		expend = -1 * received;
		if got = 1 then notgot = 0; else notgot = 1;

		below = 0; above = 0;
		if pun1 ~= 0 then do;
			if con1 <= (contrib+con2+con3) / 3 then below = below + 1; else above = above + 1;
		end;
		if pun2 ~= 0 then do;
			if con2 <= (contrib+con1+con3) / 3 then below = below + 1; else above = above + 1;
		end;
		if pun3 ~= 0 then do;
			if con3 <= (contrib+con1+con2) / 3 then below = below + 1; else above = above + 1;
		end;
		totalC = (con1+con2+con3) / 3;
		if contrib >= totalC then gave_more_than_avg = 1; else gave_more_than_avg = 0;
		diff = contrib - totalC;

		if period < 11 then set = 1; else set = 2;
		mod_period = mod(period,10);
		if mod_period = 0 then mod_period = 10;

		if diff < 0 then ndiff = diff; else ndiff = 0;
		if diff >= 0 then pdiff = diff; else pdiff = 0;

data extract;
		set jumbo;
		keep session set period subject group contrib opp1 opp2 opp3 con1
		con2 con3 pun1 pun2 pun3 received reduction mod_period base you_punished
		punish expend profit above below gave_more_than_avg got diff ndiff pdiff;

proc export data = extract outfile="&homelib/clean_data/unobserved_dataset.csv" dbms = csv replace;
