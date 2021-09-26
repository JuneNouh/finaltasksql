-- Role: "alladin"
-- DROP ROLE "alladin";

CREATE ROLE "alladin" WITH
  LOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;


CREATE DATABASE "cars"
    WITH alladin"
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

CREATE DATABASE "Task1"
    WITH 
    OWNER = "alladin"
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

--Human table--

    CREATE TABLE IF NOT EXISTS public.human
(	id integer NOT NULL DEFAULT nextval('serial1'::regclass),
    name character varying(50),
    surname character varying(45),
    PRIMARY KEY (id)
);

ALTER TABLE public.human
    OWNER to "alladin";
	
	
	
	
	
	-- Table: public.boy

-- DROP TABLE public.boy;

CREATE TABLE IF NOT EXISTS public.boy
(
    -- Inherited from table public.human: id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    -- Inherited from table public.human: name character varying(50) COLLATE pg_catalog."default",
    -- Inherited from table public.human: surname character varying(45) COLLATE pg_catalog."default",
    weight numeric(10,2),
    height numeric(10,2),
    "bornDate" date,
    CONSTRAINT boy_pkey PRIMARY KEY (id)
)
    INHERITS (public.human)
TABLESPACE pg_default;

ALTER TABLE public.boy
    OWNER to "alladin";
	
	
	
	-- Table: public.girl

-- DROP TABLE public.girl;

CREATE TABLE IF NOT EXISTS public.girl
(
    -- Inherited from table public.human: id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    -- Inherited from table public.human: name character varying(50) COLLATE pg_catalog."default",
    -- Inherited from table public.human: surname character varying(45) COLLATE pg_catalog."default",
    skin character varying(40) COLLATE pg_catalog."default",
    "eyeColor" character varying(8) COLLATE pg_catalog."default",
    age integer,
    CONSTRAINT girl_pkey PRIMARY KEY (id)
)
    INHERITS (public.human)
TABLESPACE pg_default;

ALTER TABLE public.girl
    OWNER to "alladin";


    -------------

    -- Table: public.logs

-- DROP TABLE public.logs;

CREATE TABLE IF NOT EXISTS public.logs
(
    logid integer NOT NULL DEFAULT nextval('logs_logid_seq'::regclass),
    loguser character varying(200) COLLATE pg_catalog."default",
    logoperation character varying(255) COLLATE pg_catalog."default",
    logdata character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT logs_pkey PRIMARY KEY (logid)
)

TABLESPACE pg_default;

ALTER TABLE public.logs
    OWNER to "alladin";

    --function--

    begin
INSERT INTO public.logs(
	 loguser, logoperation, logdata)
	VALUES (current_user, TG_OP, NEW.surname);
	RETURN NEW;
	END;


    -- Trigger: humanMonitoring

-- DROP TRIGGER "humanMonitoring" ON public.human;

CREATE TRIGGER "humanMonitoring"
    AFTER INSERT OR UPDATE 
    ON public.human
    FOR EACH ROW
    EXECUTE FUNCTION public."Insert_log"();


    -- Trigger: checking

-- DROP TRIGGER checking ON public.human;

CREATE TRIGGER checking
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.human
    FOR EACH ROW
    EXECUTE FUNCTION public.log_all();


    -- FUNCTION: public.log_all()

-- DROP FUNCTION public.log_all();

CREATE FUNCTION public.log_all()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
IF (TG_OP = 'DELETE') THEN
INSERT INTO public.logs(
loguser, logoperation, logdata, "tableLog")
VALUES (CURRENT_USER, TG_OP, row_to_json(OLD.*), TG_TABLE_NAME);
RETURN OLD;
ELSEIF (TG_OP='UPDATE') THEN
INSERT INTO public.logs(
loguser, logoperation, logdata, "tableLog")
VALUES (CURRENT_USER, TG_OP, (row_to_json(OLD.*)::TEXT) || (row_to_json(NEW.*)::TEXT), TG_TABLE_NAME);
RETURN OLD;
ELSEIF (TG_OP='INSERT') THEN
INSERT INTO public.logs(
loguser, logoperation, logdata, "tableLog")
VALUES (CURRENT_USER, TG_OP, row_to_json(NEW.*), TG_TABLE_NAME);
RETURN NEW;
END IF;
RETURN NULL;
END;
$BODY$;

ALTER FUNCTION public.log_all()
    OWNER TO postgres;



    -- Table: public.logs

-- DROP TABLE public.logs;

CREATE TABLE IF NOT EXISTS public.logs
(
    logid integer NOT NULL DEFAULT nextval('logs_logid_seq'::regclass),
    loguser character varying(200) COLLATE pg_catalog."default",
    logoperation character varying(255) COLLATE pg_catalog."default",
    logdata character varying(255) COLLATE pg_catalog."default",
    "tableLog" character varying(200) COLLATE pg_catalog."default",
    CONSTRAINT logs_pkey PRIMARY KEY (logid)
)

TABLESPACE pg_default;

ALTER TABLE public.logs
    OWNER to "alladin";

    -- Trigger: checkinggirl

-- DROP TRIGGER checkinggirl ON public.girl;

CREATE TRIGGER checkinggirl
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.girl
    FOR EACH ROW
    EXECUTE FUNCTION public.log_all();
