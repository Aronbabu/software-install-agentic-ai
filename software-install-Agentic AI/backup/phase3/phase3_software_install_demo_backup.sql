--
-- PostgreSQL database dump
--

\restrict OrOOInSTngDgiuej4MOjpsaEGaaG93Yck8o0VdwULF3Z2pFesxchrd24ueOEPfn

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14 (Debian 16.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: job_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.job_status AS ENUM (
    'PENDING',
    'RUNNING',
    'SUCCESS',
    'FAILED',
    'VALIDATING',
    'VERIFYING',
    'FAILED_FINAL'
);


ALTER TYPE public.job_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: app_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_roles (
    id uuid NOT NULL,
    role_name character varying(50) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.app_roles OWNER TO postgres;

--
-- Name: app_user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_user_roles (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.app_user_roles OWNER TO postgres;

--
-- Name: app_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_users (
    id uuid NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    auth_type character varying(50) NOT NULL,
    active boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.app_users OWNER TO postgres;

--
-- Name: audit_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_events (
    id character varying(36) NOT NULL,
    event_type character varying(100) NOT NULL,
    request_source character varying(50),
    request_reference character varying(255),
    job_id character varying(36),
    actor_id character varying(36),
    target_host character varying(255),
    connection_method character varying(50),
    result character varying(50),
    message character varying(1000),
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.audit_events OWNER TO postgres;

--
-- Name: authorization_decisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authorization_decisions (
    id uuid NOT NULL,
    job_id uuid,
    user_id uuid,
    request_source character varying(50) NOT NULL,
    request_reference character varying(255),
    action character varying(100) NOT NULL,
    target_host character varying(255),
    connection_method character varying(50),
    decision character varying(20) NOT NULL,
    reason text,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.authorization_decisions OWNER TO postgres;

--
-- Name: decision_ledger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.decision_ledger (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    job_id character varying(36) NOT NULL,
    request_source character varying(50) NOT NULL,
    request_reference character varying(255),
    requested_by character varying(100),
    software_name character varying(255),
    target_host character varying(255),
    connection_method character varying(50),
    authorization_result character varying(20),
    authorization_reason text,
    execution_path character varying(100),
    execution_result character varying(50),
    execution_details text,
    verification_result character varying(50),
    verification_details text,
    final_outcome character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.decision_ledger OWNER TO postgres;

--
-- Name: job_steps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_steps (
    id integer NOT NULL,
    job_id character varying NOT NULL,
    step_name character varying NOT NULL,
    status character varying NOT NULL,
    message text,
    exit_code integer,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.job_steps OWNER TO postgres;

--
-- Name: job_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_steps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_steps_id_seq OWNER TO postgres;

--
-- Name: job_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_steps_id_seq OWNED BY public.job_steps.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id character varying NOT NULL,
    ticket_id character varying NOT NULL,
    module character varying NOT NULL,
    status public.job_status NOT NULL,
    target_host character varying NOT NULL,
    os_type character varying NOT NULL,
    software_name character varying NOT NULL,
    software_version character varying,
    requested_by character varying,
    justification text,
    trace_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    max_retries integer DEFAULT 2 NOT NULL,
    timeout_seconds integer DEFAULT 300 NOT NULL,
    last_error text,
    execution_mode character varying,
    scheduled_time timestamp without time zone,
    target_port integer DEFAULT 22 NOT NULL,
    connection_method character varying(20) DEFAULT 'openssh'::character varying NOT NULL,
    request_source character varying(50) NOT NULL,
    request_reference character varying(255),
    notes text
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: service_account_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_account_credentials (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    service_name character varying(100) NOT NULL,
    api_key character varying(255) NOT NULL,
    active boolean NOT NULL,
    description character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.service_account_credentials OWNER TO postgres;

--
-- Name: software_catalogue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.software_catalogue (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    version character varying(100) NOT NULL,
    os_type character varying(50) NOT NULL,
    request_source character varying(50) NOT NULL,
    execution_mode character varying(50) NOT NULL,
    target_port character varying(20),
    connection_method character varying(50),
    status character varying(50) NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.software_catalogue OWNER TO postgres;

--
-- Name: job_steps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_steps ALTER COLUMN id SET DEFAULT nextval('public.job_steps_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
255cda0c3fd2
\.


--
-- Data for Name: app_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_roles (id, role_name, description, created_at) FROM stdin;
01737dbd-e593-4620-ae92-e9d005a996f9	Admin	Full administrative access	2026-08-26 07:22:53.491643
420085a2-cba3-44f2-ae3a-b6b081f0ed0c	Operator	Can execute approved operations	2026-08-26 07:22:53.491653
b163de52-04fe-47c1-8ae6-bb958096f483	Viewer	Read-only access	2026-08-26 07:22:53.491656
\.


--
-- Data for Name: app_user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_user_roles (id, user_id, role_id, created_at) FROM stdin;
f6271e83-7170-4c7a-be65-9cc9d26f453c	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	01737dbd-e593-4620-ae92-e9d005a996f9	2026-08-28 08:28:50.36899
c23a8ed9-14b1-475b-a898-c2a0c668de7c	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	b163de52-04fe-47c1-8ae6-bb958096f483	2026-08-28 08:59:29.854244
fcab3d6c-381a-4787-b4cc-5277deefc7c1	7edd6e16-beb0-4ce6-9339-465b24266c29	01737dbd-e593-4620-ae92-e9d005a996f9	2026-08-30 12:37:33.520125
\.


--
-- Data for Name: app_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_users (id, username, email, auth_type, active, created_at, updated_at) FROM stdin;
eae42d8f-ded1-4ab8-8943-323ff0f10431	aronbabu	aronbabu@local	local	t	2026-08-28 07:28:49.272428	2026-08-28 07:28:49.272428
7967ca5a-f324-4ffd-91de-5b3e3b4fd426	babu	babu@local	local	t	2026-08-28 07:29:37.648548	2026-08-28 07:29:37.648548
8095afc7-93ab-4bd6-9e43-e57c4eb74d05	aron	aron@local	local	t	2026-08-28 07:29:54.30189	2026-08-28 07:29:54.30189
7edd6e16-beb0-4ce6-9339-465b24266c29	servicenow_svc	servicenow@platform.local	service_account	t	2026-08-30 12:24:20.043701	2026-08-30 12:24:20.043701
\.


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_events (id, event_type, request_source, request_reference, job_id, actor_id, target_host, connection_method, result, message, created_at) FROM stdin;
495b8020-300c-4bdc-a4e1-f1528546172a	JOB_CREATED	ADMIN_PORTAL	PORTAL-001	13a6f3cd-3c72-4900-a649-d0764220c4f3	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	Execution authorization was allowed	2026-08-28 10:51:19.70304
a1c083d6-fd39-4b5b-8b89-f2044829f72f	JOB_CREATED	ADMIN_PORTAL	PORTAL-001	13a6f3cd-3c72-4900-a649-d0764220c4f3	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	CREATED	Job created successfully	2026-08-28 10:51:19.717567
9a7eee98-0800-4332-85fa-c33cf368e436	JOB_CREATED	ADMIN_PORTAL	PORTAL-001	ccb52173-d97b-4ea0-b45a-d72629a403e4	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	Execution authorization was allowed	2026-08-28 11:24:16.140845
ded4e0cc-1e29-43e9-9c0a-db562b6ee0e7	JOB_CREATED	ADMIN_PORTAL	PORTAL-001	ccb52173-d97b-4ea0-b45a-d72629a403e4	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	CREATED	Job created successfully	2026-08-28 11:24:16.145601
9d0fb527-fbff-4868-a594-926dc928de5f	AUTHORIZATION_DENIED	ADMIN_PORTAL	PORTAL-002	87f4521f-0784-4c34-940e-23393825358d	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	host.docker.internal	openssh	DENY	Execution authorization was denied	2026-08-28 11:39:09.101047
8cc213fc-0167-457d-a5a2-15b4445eb405	AUTHORIZATION_DENIED	ADMIN_PORTAL	PORTAL-002	05f28223-5bf7-48ef-8345-93b8ad24214e	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	host.docker.internal	openssh	DENY	Execution authorization was denied	2026-08-30 12:04:51.784521
904f44b5-7778-4aa3-b020-4f2467ab9f32	AUTHORIZATION_ALLOWED	SERVICENOW	RITM9999001	d1544238-c3c4-4ae9-a114-038e3aff67bc	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' authorized to create/execute this job	2026-08-30 13:53:31.774182
6aa79c24-bc16-4432-98d9-c85d77988483	JOB_CREATED	SERVICENOW	RITM9999001	d1544238-c3c4-4ae9-a114-038e3aff67bc	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	SUCCESS	Job created from SERVICENOW	2026-08-30 13:53:31.778119
2355ab7b-aae4-4e8e-b3c5-7844704a0cc7	JOB_AUTO_QUEUED	SERVICENOW	RITM9999001	d1544238-c3c4-4ae9-a114-038e3aff67bc	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	QUEUED	ServiceNow request auto-queued for execution	2026-08-30 13:53:31.918063
a0d0bd2b-b11a-4487-ad37-fa2e36baf938	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	2c134a82-9ea2-483e-9c8c-790506c677ad	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-30 13:57:55.133574
e89be975-4399-4d7c-8585-5076343d4f3c	JOB_CREATED	ADMIN_PORTAL	\N	2c134a82-9ea2-483e-9c8c-790506c677ad	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-30 13:57:55.134248
49ecaa93-0b16-43ba-a5dc-a170d43d5987	EXECUTION_DENIED	ADMIN_PORTAL	\N	2c134a82-9ea2-483e-9c8c-790506c677ad	eae42d8f-ded1-4ab8-8943-323ff0f10431	host.docker.internal	openssh	DENY	User 'aronbabu' is not authorized to execute this job	2026-08-30 13:57:55.6427
a8e379fc-846f-4ab8-8478-9fa067900f0f	AUTHORIZATION_ALLOWED	SERVICENOW	RITM9999001	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' authorized to create/execute this job	2026-08-30 14:08:47.365074
d8cbead2-0682-4876-85a0-cc79927bb54d	JOB_CREATED	SERVICENOW	RITM9999001	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	SUCCESS	Job created from SERVICENOW	2026-08-30 14:08:47.365583
3d68fd14-0514-4e70-a662-3f471b0a2d84	JOB_AUTO_QUEUED	SERVICENOW	RITM9999001	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	QUEUED	ServiceNow request auto-queued for execution	2026-08-30 14:08:47.372868
1a813916-5fc5-4f30-a469-0bcbad893112	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-30 14:17:59.065268
f5392edc-4c0d-4ba7-9f96-4706c5fe9a5e	JOB_CREATED	ADMIN_PORTAL	\N	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-30 14:17:59.065922
b73fff28-181c-4a27-9300-7d7254e29335	EXECUTION_AUTHORIZED	ADMIN_PORTAL	\N	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to execute job	2026-08-30 14:20:04.794835
71cc40d5-ae94-45d4-b153-107847812875	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	a7de03cb-9545-453c-9ef6-36a861ddd509	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-30 14:36:32.431241
758939d5-5b0d-4bbe-b6e8-182525599374	JOB_CREATED	ADMIN_PORTAL	\N	a7de03cb-9545-453c-9ef6-36a861ddd509	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-30 14:36:32.434431
f46069ea-7c36-4475-b361-3878222afa1b	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	fabcf2a8-1b80-4dc3-a53e-33339cd66c18	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-30 14:39:38.182867
35898b50-a505-496b-b39b-a3af980d8600	JOB_CREATED	ADMIN_PORTAL	\N	fabcf2a8-1b80-4dc3-a53e-33339cd66c18	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-30 14:39:38.184931
38f93ca5-4ff0-4097-bb4c-3d3ea848248b	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	2123c253-287d-4fdd-bf72-f48871682f3f	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-30 14:40:08.309481
801eb6c4-532f-4f62-9940-8dadc551f32c	JOB_CREATED	ADMIN_PORTAL	\N	2123c253-287d-4fdd-bf72-f48871682f3f	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-30 14:40:08.310848
2b72ddb7-262f-47a5-8088-a6d8560d5b1a	AUTHORIZATION_ALLOWED	SERVICENOW	RITM9999001	5ca70672-caac-4008-be0f-ebec84e9072f	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' authorized to create/execute this job	2026-08-30 14:42:43.481776
a836c40c-6263-4149-8e79-223ea0d20371	JOB_CREATED	SERVICENOW	RITM9999001	5ca70672-caac-4008-be0f-ebec84e9072f	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	SUCCESS	Job created from SERVICENOW	2026-08-30 14:42:43.482251
befd078b-af0b-4d1a-a83b-1deceac27b25	JOB_AUTO_QUEUED	SERVICENOW	RITM9999001	5ca70672-caac-4008-be0f-ebec84e9072f	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	QUEUED	ServiceNow request auto-queued for execution	2026-08-30 14:42:43.554047
7e7ccf90-9a7c-4198-aaeb-4976d8299ac8	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	7bd02baf-ce5a-4826-92a6-dbe24419c271	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-30 14:44:25.749278
12e41c84-0cfc-4b7b-8663-e2a08f0947f8	JOB_CREATED	ADMIN_PORTAL	\N	7bd02baf-ce5a-4826-92a6-dbe24419c271	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-30 14:44:25.749813
8661c8cc-02ef-4903-9b26-a9c296255995	EXECUTION_AUTHORIZED	ADMIN_PORTAL	\N	7bd02baf-ce5a-4826-92a6-dbe24419c271	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to execute job	2026-08-30 14:46:05.552555
45795b4d-f0de-4681-8dd2-eff40134ea75	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	7e5d8179-9920-4b00-a382-06aa0964a61b	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-31 09:15:49.988735
df8d6e3f-b25e-4764-8fd8-94390cc593ea	JOB_CREATED	ADMIN_PORTAL	\N	7e5d8179-9920-4b00-a382-06aa0964a61b	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-31 09:15:50.032963
5301406d-c43f-4169-8460-ca9a42656894	EXECUTION_AUTHORIZED	ADMIN_PORTAL	\N	7e5d8179-9920-4b00-a382-06aa0964a61b	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to execute job	2026-08-31 09:16:54.751686
1d216484-8e2c-4979-96d8-3f34153a2e31	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	6234cd22-e8c9-4603-8643-5e97b3476d78	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-31 09:19:56.22249
989a66f0-b53c-44e7-a621-67fff3e2a88c	JOB_CREATED	ADMIN_PORTAL	\N	6234cd22-e8c9-4603-8643-5e97b3476d78	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-31 09:19:56.228836
357eda90-481a-48cc-b736-4e82c20dde99	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	265be063-69d5-4a0c-a2ea-4e43d876e80d	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-08-31 09:23:32.749462
16b71fbd-5a5a-44dd-8cc1-a40b189e9e98	JOB_CREATED	ADMIN_PORTAL	\N	265be063-69d5-4a0c-a2ea-4e43d876e80d	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-08-31 09:23:32.755931
1588cab6-8941-4f19-b52a-0112fe0c7b6e	EXECUTION_AUTHORIZED	ADMIN_PORTAL	\N	265be063-69d5-4a0c-a2ea-4e43d876e80d	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to execute job	2026-08-31 09:24:28.236445
a4aa70e6-acfc-4ea3-800c-280ae401ad29	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	0b742fe1-4149-45e6-8dc3-b4b342e433db	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-09-01 07:21:00.997568
92323e8a-2b4e-4c9b-94a2-5c7f9128b9e6	JOB_CREATED	ADMIN_PORTAL	\N	0b742fe1-4149-45e6-8dc3-b4b342e433db	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-09-01 07:21:01.002009
eec857b2-7eaf-408a-8e60-3d729059170f	EXECUTION_AUTHORIZED	ADMIN_PORTAL	\N	0b742fe1-4149-45e6-8dc3-b4b342e433db	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to execute job	2026-09-01 07:23:41.009468
49654eaf-155d-498f-8f60-96f9ac0257d3	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	\N	6fc1dff3-5f11-42a1-b308-a0343702a9ee	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-09-01 07:25:34.212515
8a6c4ed9-5a14-40ff-a55e-ae9d2b70f07f	JOB_CREATED	ADMIN_PORTAL	\N	6fc1dff3-5f11-42a1-b308-a0343702a9ee	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-09-01 07:25:34.215215
506b411f-55f7-4323-ab1d-cf8eb8b32df7	EXECUTION_AUTHORIZED	ADMIN_PORTAL	\N	6fc1dff3-5f11-42a1-b308-a0343702a9ee	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to execute job	2026-09-01 07:25:42.080268
4ce8f278-29db-4573-ba5f-f0636f52e195	AUTHORIZATION_ALLOWED	SERVICENOW	RITM9999005	34658c01-57c9-40a7-b2a7-b3036347fafc	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' authorized to create/execute this job	2026-09-01 10:13:48.525526
ea81ef63-6769-4d74-932c-6d89d36ceea2	JOB_CREATED	SERVICENOW	RITM9999005	34658c01-57c9-40a7-b2a7-b3036347fafc	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	SUCCESS	Job created from SERVICENOW	2026-09-01 10:13:48.540364
d53fde2e-af64-47ce-9ec5-7555f4d32827	JOB_AUTO_QUEUED	SERVICENOW	RITM9999005	34658c01-57c9-40a7-b2a7-b3036347fafc	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	QUEUED	ServiceNow request auto-queued for execution	2026-09-01 10:13:48.853543
cac6dca4-94e8-4b92-b9ef-d7c1c7da47fe	AUTHORIZATION_ALLOWED	SERVICENOW	RITM9991003	8b351617-3422-4c47-b096-507cf8c56931	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' authorized to create/execute this job	2026-09-01 10:19:49.975977
bbc4a7db-2c1d-497b-9b74-94cce4d70039	JOB_CREATED	SERVICENOW	RITM9991003	8b351617-3422-4c47-b096-507cf8c56931	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	SUCCESS	Job created from SERVICENOW	2026-09-01 10:19:49.99451
d3fc5e21-476e-45f4-97ab-81a849a98cee	JOB_AUTO_QUEUED	SERVICENOW	RITM9991003	8b351617-3422-4c47-b096-507cf8c56931	7edd6e16-beb0-4ce6-9339-465b24266c29	host.docker.internal	openssh	QUEUED	ServiceNow request auto-queued for execution	2026-09-01 10:19:50.049721
92ac07e9-e5f6-4ebe-a809-d92a7e9957bc	AUTHORIZATION_DENIED	ADMIN_PORTAL	RITM9919004	532a7329-068f-43e4-ad84-aa2f2e1c5277	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	host.docker.internal	openssh	DENY	User 'babu' is not authorized to create/execute this job	2026-09-01 10:22:08.039356
78dd90cc-4120-4392-a365-c5fcf2d8d1dd	AUTHORIZATION_DENIED	ADMIN_PORTAL	RITM9919004	3158e3bf-16c8-4707-bb06-27c1983ca81f	eae42d8f-ded1-4ab8-8943-323ff0f10431	host.docker.internal	openssh	DENY	User 'aronbabu' is not authorized to create/execute this job	2026-09-01 10:22:17.221017
4cd6271e-a8ec-4aee-9d2d-a2aa289626ec	AUTHORIZATION_ALLOWED	ADMIN_PORTAL	RITM9919004	d7797519-07cc-4943-810d-f0928fd2d2f1	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	ALLOW	User 'aron' authorized to create/execute this job	2026-09-01 10:23:56.135968
43976877-1cd5-4e66-b3e6-e2596554c851	JOB_CREATED	ADMIN_PORTAL	RITM9919004	d7797519-07cc-4943-810d-f0928fd2d2f1	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	host.docker.internal	openssh	SUCCESS	Job created from ADMIN_PORTAL	2026-09-01 10:23:56.141304
\.


--
-- Data for Name: authorization_decisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.authorization_decisions (id, job_id, user_id, request_source, request_reference, action, target_host, connection_method, decision, reason, created_at) FROM stdin;
e2b52f31-75cf-4803-907b-f559c525f62d	13a6f3cd-3c72-4900-a649-d0764220c4f3	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	PORTAL-001	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-28 10:51:19.656148
7191a9ad-db39-4c9f-b189-4c1496e1183b	ccb52173-d97b-4ea0-b45a-d72629a403e4	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	PORTAL-001	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-28 11:24:16.123553
5a0d22df-18bb-4349-b78c-502a47126bfb	87f4521f-0784-4c34-940e-23393825358d	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	ADMIN_PORTAL	PORTAL-002	EXECUTE	host.docker.internal	openssh	DENY	User does not have the required role(s) for this action.	2026-08-28 11:39:09.071747
ccefd741-a843-4000-aa77-eddb73a8b3c9	05f28223-5bf7-48ef-8345-93b8ad24214e	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	ADMIN_PORTAL	PORTAL-002	EXECUTE	host.docker.internal	openssh	DENY	User does not have the required role(s) for this action.	2026-08-30 12:04:51.766196
4baccbfd-877a-4097-a87c-9e855ca107b7	d1544238-c3c4-4ae9-a114-038e3aff67bc	7edd6e16-beb0-4ce6-9339-465b24266c29	SERVICENOW	RITM9999001	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 13:53:31.762676
8333ff00-9c29-4135-8f30-dd9048f2577d	2c134a82-9ea2-483e-9c8c-790506c677ad	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 13:57:55.1277
d4ba074d-a672-4423-a1bc-f0fb50f887a3	2c134a82-9ea2-483e-9c8c-790506c677ad	eae42d8f-ded1-4ab8-8943-323ff0f10431	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	DENY	User does not have the required role(s) for this action.	2026-08-30 13:57:55.639603
2fe5db0c-4aae-4473-8b09-3d6406bc34db	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	7edd6e16-beb0-4ce6-9339-465b24266c29	SERVICENOW	RITM9999001	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:08:47.360742
8095d653-d636-433a-bf07-f4c12e9be46a	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:17:59.061633
8c6c4dfa-2f67-45c5-9ee8-66f619c080a5	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:20:04.782767
2901b898-2ae5-4a72-8ec4-da06fa656493	a7de03cb-9545-453c-9ef6-36a861ddd509	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:36:32.41736
737aa54f-df3e-4f19-a64f-6ba0f77a7be9	fabcf2a8-1b80-4dc3-a53e-33339cd66c18	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:39:38.163147
9bad57fe-9bc6-41d6-9465-bb7bf7c5fa40	2123c253-287d-4fdd-bf72-f48871682f3f	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:40:08.303439
6882e605-e4dd-4ab3-9282-e6d09477c0e2	5ca70672-caac-4008-be0f-ebec84e9072f	7edd6e16-beb0-4ce6-9339-465b24266c29	SERVICENOW	RITM9999001	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:42:43.477914
9b765ab5-655d-4fdc-b6b7-a02ba6233ca8	7bd02baf-ce5a-4826-92a6-dbe24419c271	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:44:25.742912
5e8271eb-6220-4417-b641-a4aacecc048e	7bd02baf-ce5a-4826-92a6-dbe24419c271	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-30 14:46:05.54798
2a0949d2-c5df-4380-8e1b-38806d671a7a	7e5d8179-9920-4b00-a382-06aa0964a61b	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-31 09:15:49.943
adf4d0e6-0d76-4823-97c1-c1307165f23f	7e5d8179-9920-4b00-a382-06aa0964a61b	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-31 09:16:54.731138
94ce0a39-0fee-49c2-a89b-fb19414b79f7	6234cd22-e8c9-4603-8643-5e97b3476d78	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-31 09:19:56.214468
2011398a-d8e2-4d8f-bbc8-801ed71c6407	265be063-69d5-4a0c-a2ea-4e43d876e80d	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-31 09:23:32.739903
c43f8f77-7381-4f10-a553-0093c377b094	265be063-69d5-4a0c-a2ea-4e43d876e80d	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-08-31 09:24:28.224735
4e2f4ad3-bea8-4991-bb9c-c15c87d7a7ae	0b742fe1-4149-45e6-8dc3-b4b342e433db	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 07:21:00.989628
27ec2068-00d5-4179-8fc7-c6b7b17999db	0b742fe1-4149-45e6-8dc3-b4b342e433db	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 07:23:41.005974
bd9b181c-d193-4819-94b5-5f92a1a7fa6b	6fc1dff3-5f11-42a1-b308-a0343702a9ee	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 07:25:34.205904
88b230b7-1225-4524-9fa0-4af9cbdfeca1	6fc1dff3-5f11-42a1-b308-a0343702a9ee	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	\N	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 07:25:42.076264
c1c51e77-c362-4deb-96be-fb841e6ee7c8	34658c01-57c9-40a7-b2a7-b3036347fafc	7edd6e16-beb0-4ce6-9339-465b24266c29	SERVICENOW	RITM9999005	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 10:13:48.492598
70c83ba1-ee55-470e-b680-306af153303c	8b351617-3422-4c47-b096-507cf8c56931	7edd6e16-beb0-4ce6-9339-465b24266c29	SERVICENOW	RITM9991003	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 10:19:49.968808
f655b887-c923-4a01-92da-0a47b4b83515	532a7329-068f-43e4-ad84-aa2f2e1c5277	7967ca5a-f324-4ffd-91de-5b3e3b4fd426	ADMIN_PORTAL	RITM9919004	EXECUTE	host.docker.internal	openssh	DENY	User does not have the required role(s) for this action.	2026-09-01 10:22:08.031061
1583dd8e-8e5b-4890-b801-965df0046b9b	3158e3bf-16c8-4707-bb06-27c1983ca81f	eae42d8f-ded1-4ab8-8943-323ff0f10431	ADMIN_PORTAL	RITM9919004	EXECUTE	host.docker.internal	openssh	DENY	User does not have the required role(s) for this action.	2026-09-01 10:22:17.210206
ff3a12fe-04e2-4639-ac59-31fe043d5aa9	d7797519-07cc-4943-810d-f0928fd2d2f1	8095afc7-93ab-4bd6-9e43-e57c4eb74d05	ADMIN_PORTAL	RITM9919004	EXECUTE	host.docker.internal	openssh	ALLOW	User has the required role(s) for this action.	2026-09-01 10:23:56.131525
\.


--
-- Data for Name: decision_ledger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.decision_ledger (id, job_id, request_source, request_reference, requested_by, software_name, target_host, connection_method, authorization_result, authorization_reason, execution_path, execution_result, execution_details, verification_result, verification_details, final_outcome, created_at, updated_at) FROM stdin;
76531115-c03e-4f72-ab31-98e6dbbab253	7e5d8179-9920-4b00-a382-06aa0964a61b	ADMIN_PORTAL	\N	aron	curl1	host.docker.internal	openssh	ALLOW	User 'aron' is authorized	openssh	\N	\N	\N	\N	\N	2026-08-31 09:15:49.908558	2026-08-31 09:15:50.02561
60b4eac5-4efc-46fc-b9be-db53ba6374f5	6234cd22-e8c9-4603-8643-5e97b3476d78	ADMIN_PORTAL	\N	aron	curl	host.docker.internal	openssh	ALLOW	User 'aron' is authorized	openssh	\N	\N	\N	\N	\N	2026-08-31 09:19:56.207181	2026-08-31 09:19:56.227062
2cb0ed75-2455-4fd2-846d-5d58eda7c345	8b351617-3422-4c47-b096-507cf8c56931	SERVICENOW	RITM9991003	servicenow_svc	curl	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' is authorized	openssh	SUCCESS	exit_code=0; duration=5.61s; stdout=/usr/bin/curl\n; stderr=N/A	SUCCESS	Verification output: /usr/bin/curl\n	SUCCESS	2026-09-01 10:19:49.965022	2026-09-01 10:20:20.738276
3c52a638-15be-4502-a66d-ccc9c06285ab	265be063-69d5-4a0c-a2ea-4e43d876e80d	ADMIN_PORTAL	\N	aron	curl	host.docker.internal	openssh	ALLOW	User 'aron' is authorized	openssh	SUCCESS	exit_code=0; duration=9.25s; stdout=/usr/bin/curl\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	SUCCESS	Verification output: /usr/bin/curl\n	SUCCESS	2026-08-31 09:23:32.73557	2026-08-31 09:25:03.11522
4ebec495-8e8d-4180-acae-896f0c912224	532a7329-068f-43e4-ad84-aa2f2e1c5277	ADMIN_PORTAL	RITM9919004	babu	curl	host.docker.internal	openssh	DENY	User 'babu' is not authorized	openssh	\N	\N	\N	\N	DENIED	2026-09-01 10:22:08.02452	2026-09-01 10:22:08.043413
be369b68-03e1-4218-92cd-4aec1d985f21	3158e3bf-16c8-4707-bb06-27c1983ca81f	ADMIN_PORTAL	RITM9919004	aronbabu	curl	host.docker.internal	openssh	DENY	User 'aronbabu' is not authorized	openssh	\N	\N	\N	\N	DENIED	2026-09-01 10:22:17.204241	2026-09-01 10:22:17.223785
fa349f2d-b5f5-4eba-bfcd-07807d1bfce0	0b742fe1-4149-45e6-8dc3-b4b342e433db	ADMIN_PORTAL	\N	aron	vim	host.docker.internal	openssh	ALLOW	User 'aron' is authorized	openssh	FAILED	exit_code=-1; duration=0.02s; stdout=N/A; stderr=[Errno None] Unable to connect to port 2221 on 192.168.65.254	FAILED	Verification output: N/A	FAILED	2026-09-01 07:21:00.98278	2026-09-01 07:25:36.402711
c8cfa932-f532-4736-b669-9059aded7938	d7797519-07cc-4943-810d-f0928fd2d2f1	ADMIN_PORTAL	RITM9919004	aron	curl	host.docker.internal	openssh	ALLOW	User 'aron' is authorized	openssh	\N	\N	\N	\N	\N	2026-09-01 10:23:56.128626	2026-09-01 10:23:56.137976
fcfce593-070e-4136-bd74-10a0e3e9a400	6fc1dff3-5f11-42a1-b308-a0343702a9ee	ADMIN_PORTAL	\N	aron	vim	host.docker.internal	openssh	ALLOW	User 'aron' is authorized	openssh	SUCCESS	exit_code=0; duration=3.12s; stdout=/usr/bin/vim\n; stderr=N/A	SUCCESS	Verification output: /usr/bin/vim\n	SUCCESS	2026-09-01 07:25:34.202185	2026-09-01 07:26:10.237784
b2458992-b081-4b44-9f49-d3bd9adca3f7	34658c01-57c9-40a7-b2a7-b3036347fafc	SERVICENOW	RITM9999005	servicenow_svc	curl	host.docker.internal	openssh	ALLOW	User 'servicenow_svc' is authorized	openssh	SUCCESS	exit_code=0; duration=4.34s; stdout=/usr/bin/curl\n; stderr=N/A	SUCCESS	Verification output: /usr/bin/curl\n	SUCCESS	2026-09-01 10:13:48.449942	2026-09-01 10:14:18.751541
\.


--
-- Data for Name: job_steps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_steps (id, job_id, step_name, status, message, exit_code, created_at) FROM stdin;
1	324f6daf-d333-4280-9b99-fa7dee9ecaab	job_received	SUCCESS	Job request accepted and stored	0	2026-06-21 14:47:20.427927
2	324f6daf-d333-4280-9b99-fa7dee9ecaab	status_validating	VALIDATING	Validation started	0	2026-06-21 14:47:32.782654
3	324f6daf-d333-4280-9b99-fa7dee9ecaab	status_running	RUNNING	Execution started	0	2026-06-21 14:47:42.812766
4	324f6daf-d333-4280-9b99-fa7dee9ecaab	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=0.22s; stdout=Installing curl\n; stderr=	0	2026-06-21 14:47:58.051882
5	324f6daf-d333-4280-9b99-fa7dee9ecaab	execution_time	SUCCESS	Execution took 0.22 seconds	0	2026-06-21 14:47:58.051888
6	324f6daf-d333-4280-9b99-fa7dee9ecaab	status_verifying	VERIFYING	Verification started	0	2026-06-21 14:48:08.079556
7	324f6daf-d333-4280-9b99-fa7dee9ecaab	status_success	SUCCESS	Execution completed successfully	0	2026-06-21 14:48:18.106105
8	ba5dc69a-039f-472b-9bdb-2f88ca5e8992	job_received	SUCCESS	Job request accepted and stored	0	2026-06-21 14:56:32.78679
9	ba5dc69a-039f-472b-9bdb-2f88ca5e8992	status_validating	VALIDATING	Validation started	0	2026-06-21 14:56:42.126608
10	ba5dc69a-039f-472b-9bdb-2f88ca5e8992	status_running	RUNNING	Execution started	0	2026-06-21 14:56:52.16345
11	019a244a-2739-467e-9eab-be388626928b	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 11:04:14.986148
12	019a244a-2739-467e-9eab-be388626928b	status_validating	VALIDATING	Validation started	0	2026-06-23 11:04:25.615784
13	019a244a-2739-467e-9eab-be388626928b	status_running	RUNNING	Execution started	0	2026-06-23 11:04:35.63324
14	019a244a-2739-467e-9eab-be388626928b	status_failed	FAILED	Execution exception: Software 'vim' not approved for os_type 'linux'	0	2026-06-23 11:04:50.740248
15	588390e1-a563-4568-9289-1bdecf3a4acf	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 11:09:07.04184
16	588390e1-a563-4568-9289-1bdecf3a4acf	status_validating	VALIDATING	Validation started	0	2026-06-23 11:09:13.387401
17	588390e1-a563-4568-9289-1bdecf3a4acf	status_running	RUNNING	Execution started	0	2026-06-23 11:09:23.409651
18	588390e1-a563-4568-9289-1bdecf3a4acf	status_failed	FAILED	Execution exception: Software 'vim' not approved for os_type 'linux'	0	2026-06-23 11:09:38.481422
19	ac518ad0-ac03-4f0a-946f-80c0977fccf0	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 11:10:38.371616
20	ac518ad0-ac03-4f0a-946f-80c0977fccf0	status_validating	VALIDATING	Validation started	0	2026-06-23 11:10:42.121616
21	ac518ad0-ac03-4f0a-946f-80c0977fccf0	status_running	RUNNING	Execution started	0	2026-06-23 11:10:52.141109
22	ac518ad0-ac03-4f0a-946f-80c0977fccf0	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=6.99s; stdout=VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 18 2023 09:20:34)\nIncluded patches: 1-1453, 3625, 3669, 3741\nModified by pkg-vim-maintainers@lists.alioth.debian.org\nCompiled by pkg-vim-maintainers@lists.alioth.debian.org\nHuge version without GUI.  Features included (+) or not (-):\n+acl             ; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-06-23 11:11:14.140564
23	ac518ad0-ac03-4f0a-946f-80c0977fccf0	verification_result	SUCCESS	Verification output: VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 18 2023 09:20:34)\nIncluded patches: 1-1453, 3625, 3669, 3741\nModified by pkg-vim-maintainers@lists.alioth.debian.org\nCompiled by pkg-vim-maintainers@lists.alioth.debian.org\nHuge version without GUI.  Features included (+) or not (-):\n+acl               +farsi             +mouse_sgr         -tag_any_white\n+arabic            +file_in_path      -mouse_sysmouse    -tcl\n+autocmd           +find_in_path      +mouse_urxvt       +termguicolors\n-autoservername    +float             +mouse_xterm       +terminal\n-balloon_eval      +folding           +multi_byte        +terminfo\n+balloon_eval_term -footer            +multi_lang        +termresponse\n-browse            +fork()            -mzscheme          +textobjects\n++builtin_terms    +gettext           +netbeans_intg     +timers\n+byte_offset       -hangul_input      +num64             +title\n+channel           +iconv             +packages          -toolbar\n+cindent           +insert_expand     +path_extra        +user_commands\n-clientserver      +job               -perl              +vertsplit\n-clipboard         +jumplist          +persistent_undo   +virtualedit\n+cmdline_compl     +keymap            +postscript        +visual\n+cmdline_hist      +lambda            +printer           +visualextra\n+cmdline_info      +langmap           +profile           +viminfo\n+comments          +libcall           -python            +vreplace\n+conceal           +linebreak         +python3           +wildignore\n+cryptv            +lispindent        +quickfix          +wildmenu\n+cscope            +listcmds          +reltime           +windows\n+cursorbind        +localmap          +rightleft         +writebackup\n+cursorshape       -lua               -ruby              -X11\n+dialog_con        +menu              +scrollbind        -xfontset\n+diff              +mksession         +signs             -xim\n+digraphs          +modify_fname      +smartindent       -xpm\n-dnd               +mouse             +startuptime       -xsmp\n-ebcdic            -mouseshape        +statusline        -xterm_clipboard\n+emacs_tags        +mouse_dec         -sun_workshop      -xterm_save\n+eval              +mouse_gpm         +syntax            \n+ex_extra          -mouse_jsbterm     +tag_binary        \n+extra_search      +mouse_netterm     +tag_old_static    \n   system vimrc file: "$VIM/vimrc"\n     user vimrc file: "$HOME/.vimrc"\n 2nd user vimrc file: "~/.vim/vimrc"\n      user exrc file: "$HOME/.exrc"\n       defaults file: "$VIMRUNTIME/defaults.vim"\n  fall-back for $VIM: "/usr/share/vim"\nCompilation: gcc -c -I. -Iproto -DHAVE_CONFIG_H   -Wdate-time  -g -O2 -fdebug-prefix-map=/build/vim-bW1j6S/vim-8.0.1453=. -fstack-protector-strong -Wformat -Werror=format-security -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1       \nLinking: gcc   -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -o vim        -lm -ltinfo -lnsl  -lselinux  -lacl -lattr -lgpm -ldl     -L/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu -lpython3.6m -lpthread -ldl -lutil -lm      \n	0	2026-06-23 11:11:14.140568
24	ac518ad0-ac03-4f0a-946f-80c0977fccf0	execution_time	SUCCESS	Execution took 6.99 seconds	0	2026-06-23 11:11:14.14841
25	ac518ad0-ac03-4f0a-946f-80c0977fccf0	status_verifying	VERIFYING	Verification started	0	2026-06-23 11:11:24.163987
26	ac518ad0-ac03-4f0a-946f-80c0977fccf0	status_success	SUCCESS	Execution completed successfully	0	2026-06-23 11:11:34.177363
27	1850dc66-f0b3-42cc-aa32-5e4ad390a6db	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 12:24:57.501834
28	1850dc66-f0b3-42cc-aa32-5e4ad390a6db	status_validating	VALIDATING	Validation started	0	2026-06-23 12:25:12.237688
29	1850dc66-f0b3-42cc-aa32-5e4ad390a6db	status_running	RUNNING	Execution started	0	2026-06-23 12:25:22.25558
30	1850dc66-f0b3-42cc-aa32-5e4ad390a6db	status_failed	FAILED	Execution exception: 'install'	0	2026-06-23 12:25:37.316875
31	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 12:53:45.980163
32	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	status_validating	VALIDATING	Validation started	0	2026-06-23 12:53:53.658147
33	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	status_running	RUNNING	Execution started	0	2026-06-23 12:54:03.683717
34	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 12:54:18.704974
35	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	verification_result	FAILED	Verification output: 	1	2026-06-23 12:54:18.7169
36	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 12:54:18.728063
37	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	status_verifying	VERIFYING	Verification started	0	2026-06-23 12:54:28.743446
38	ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-23 12:54:38.763929
39	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 13:05:52.04405
40	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_validating	VALIDATING	Validation started	0	2026-06-23 13:06:00.409587
41	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_running	RUNNING	Execution started	0	2026-06-23 13:06:10.44001
42	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:06:25.4628
43	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	verification_result	FAILED	Verification output: 	1	2026-06-23 13:06:25.47526
45	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:06:35.509754
46	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-23 13:06:45.528398
48	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_running	RUNNING	Execution started	0	2026-06-23 13:06:55.57502
50	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	verification_result	FAILED	Verification output: 	1	2026-06-23 13:07:10.607927
52	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:07:20.628176
53	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	retry_attempt	FAILED	Attempt 2 failed	1	2026-06-23 13:07:30.660434
55	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_running	RUNNING	Execution started	0	2026-06-23 13:07:40.70994
57	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	verification_result	FAILED	Verification output: 	1	2026-06-23 13:07:55.743418
59	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:08:05.766135
60	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	retry_attempt	FAILED	Attempt 3 failed	1	2026-06-23 13:08:15.789301
62	dee5feb6-07f7-4174-8801-fa3258766e7f	status_validating	VALIDATING	Validation started	0	2026-06-23 13:09:27.97324
64	dee5feb6-07f7-4174-8801-fa3258766e7f	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:09:53.006395
66	dee5feb6-07f7-4174-8801-fa3258766e7f	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:09:53.030784
67	dee5feb6-07f7-4174-8801-fa3258766e7f	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:10:03.052796
44	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:06:25.493226
47	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_validating	VALIDATING	Validation started	0	2026-06-23 13:06:45.559186
49	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:07:10.600312
51	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:07:10.614759
54	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	status_validating	VALIDATING	Validation started	0	2026-06-23 13:07:30.694676
56	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:07:55.733988
58	6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:07:55.752721
61	dee5feb6-07f7-4174-8801-fa3258766e7f	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 13:09:19.454697
63	dee5feb6-07f7-4174-8801-fa3258766e7f	status_running	RUNNING	Execution started	0	2026-06-23 13:09:37.987792
65	dee5feb6-07f7-4174-8801-fa3258766e7f	verification_result	FAILED	Verification output: 	1	2026-06-23 13:09:53.020053
68	dee5feb6-07f7-4174-8801-fa3258766e7f	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-23 13:10:13.084471
69	dee5feb6-07f7-4174-8801-fa3258766e7f	status_validating	VALIDATING	Validation started	0	2026-06-23 13:10:13.112026
70	dee5feb6-07f7-4174-8801-fa3258766e7f	status_running	RUNNING	Execution started	0	2026-06-23 13:10:23.231039
71	dee5feb6-07f7-4174-8801-fa3258766e7f	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:10:38.252202
72	dee5feb6-07f7-4174-8801-fa3258766e7f	verification_result	FAILED	Verification output: 	1	2026-06-23 13:10:38.280881
73	dee5feb6-07f7-4174-8801-fa3258766e7f	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:10:38.293635
74	dee5feb6-07f7-4174-8801-fa3258766e7f	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:10:48.308361
75	dee5feb6-07f7-4174-8801-fa3258766e7f	retry_attempt	FAILED	Attempt 2 failed	1	2026-06-23 13:10:58.347126
76	dee5feb6-07f7-4174-8801-fa3258766e7f	status_validating	VALIDATING	Validation started	0	2026-06-23 13:10:58.385514
77	dee5feb6-07f7-4174-8801-fa3258766e7f	status_running	RUNNING	Execution started	0	2026-06-23 13:11:08.412693
78	dee5feb6-07f7-4174-8801-fa3258766e7f	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:11:23.436925
79	dee5feb6-07f7-4174-8801-fa3258766e7f	verification_result	FAILED	Verification output: 	1	2026-06-23 13:11:23.443449
80	dee5feb6-07f7-4174-8801-fa3258766e7f	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:11:23.450546
81	dee5feb6-07f7-4174-8801-fa3258766e7f	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:11:33.461669
82	dee5feb6-07f7-4174-8801-fa3258766e7f	retry_attempt	FAILED	Attempt 3 failed	1	2026-06-23 13:11:43.508854
83	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 13:23:20.07852
84	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_validating	VALIDATING	Validation started	0	2026-06-23 13:23:39.036234
85	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_running	RUNNING	Execution started	0	2026-06-23 13:23:49.050186
86	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:24:04.076767
87	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	verification_result	FAILED	Verification output: 	1	2026-06-23 13:24:04.105069
88	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:24:04.109941
89	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:24:14.120557
90	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-23 13:24:24.141045
91	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_validating	VALIDATING	Validation started	0	2026-06-23 13:24:24.179212
92	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_running	RUNNING	Execution started	0	2026-06-23 13:24:34.192085
93	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:24:49.228102
94	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	verification_result	FAILED	Verification output: 	1	2026-06-23 13:24:49.246421
95	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:24:49.25662
96	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:24:59.272648
97	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	retry_attempt	FAILED	Attempt 2 failed	1	2026-06-23 13:25:09.31187
98	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_validating	VALIDATING	Validation started	0	2026-06-23 13:25:09.333457
99	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_running	RUNNING	Execution started	0	2026-06-23 13:25:19.348789
100	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:25:34.362966
101	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	verification_result	FAILED	Verification output: 	1	2026-06-23 13:25:34.372377
102	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:25:34.383632
103	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:25:44.396329
104	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	retry_attempt	FAILED	Attempt 3 failed	1	2026-06-23 13:25:54.4187
105	8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-06-23 13:25:54.426705
106	e811b047-ebf2-41e2-983c-80cacea461fd	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 13:29:02.081811
107	e811b047-ebf2-41e2-983c-80cacea461fd	status_validating	VALIDATING	Validation started	0	2026-06-23 13:29:06.28601
108	e811b047-ebf2-41e2-983c-80cacea461fd	status_running	RUNNING	Execution started	0	2026-06-23 13:29:16.301136
109	e811b047-ebf2-41e2-983c-80cacea461fd	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:29:31.318131
110	e811b047-ebf2-41e2-983c-80cacea461fd	verification_result	FAILED	Verification output: 	1	2026-06-23 13:29:31.330132
111	e811b047-ebf2-41e2-983c-80cacea461fd	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:29:31.342583
112	e811b047-ebf2-41e2-983c-80cacea461fd	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:29:41.359615
113	e811b047-ebf2-41e2-983c-80cacea461fd	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-23 13:29:51.39848
114	e811b047-ebf2-41e2-983c-80cacea461fd	status_validating	VALIDATING	Validation started	0	2026-06-23 13:29:51.423198
115	e811b047-ebf2-41e2-983c-80cacea461fd	status_running	RUNNING	Execution started	0	2026-06-23 13:30:01.430999
116	e811b047-ebf2-41e2-983c-80cacea461fd	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:30:16.4444
118	e811b047-ebf2-41e2-983c-80cacea461fd	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:30:16.467836
121	e811b047-ebf2-41e2-983c-80cacea461fd	status_validating	VALIDATING	Validation started	0	2026-06-23 13:30:36.551832
123	e811b047-ebf2-41e2-983c-80cacea461fd	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:31:01.574978
125	e811b047-ebf2-41e2-983c-80cacea461fd	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:31:01.602857
117	e811b047-ebf2-41e2-983c-80cacea461fd	verification_result	FAILED	Verification output: 	1	2026-06-23 13:30:16.454957
119	e811b047-ebf2-41e2-983c-80cacea461fd	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:30:26.486106
120	e811b047-ebf2-41e2-983c-80cacea461fd	retry_attempt	FAILED	Attempt 2 failed	1	2026-06-23 13:30:36.523557
122	e811b047-ebf2-41e2-983c-80cacea461fd	status_running	RUNNING	Execution started	0	2026-06-23 13:30:46.562584
124	e811b047-ebf2-41e2-983c-80cacea461fd	verification_result	FAILED	Verification output: 	1	2026-06-23 13:31:01.591106
126	e811b047-ebf2-41e2-983c-80cacea461fd	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:31:11.618811
127	e811b047-ebf2-41e2-983c-80cacea461fd	retry_attempt	FAILED	Attempt 3 failed	1	2026-06-23 13:31:21.641354
128	e811b047-ebf2-41e2-983c-80cacea461fd	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-06-23 13:31:21.651478
129	46a51e5a-87d2-4a83-b24b-3f84162a8287	job_received	SUCCESS	Job request accepted and stored	0	2026-06-23 13:48:41.772545
130	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_validating	VALIDATING	Validation started	0	2026-06-23 13:48:44.617876
131	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_running	RUNNING	Execution started	0	2026-06-23 13:48:54.637501
132	46a51e5a-87d2-4a83-b24b-3f84162a8287	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:49:09.674149
133	46a51e5a-87d2-4a83-b24b-3f84162a8287	verification_result	FAILED	Verification output: 	1	2026-06-23 13:49:09.697584
134	46a51e5a-87d2-4a83-b24b-3f84162a8287	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:49:09.708308
135	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:49:19.727018
136	46a51e5a-87d2-4a83-b24b-3f84162a8287	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-23 13:49:29.756731
137	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_validating	VALIDATING	Validation started	0	2026-06-23 13:49:29.776978
138	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_running	RUNNING	Execution started	0	2026-06-23 13:49:39.78741
139	46a51e5a-87d2-4a83-b24b-3f84162a8287	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:49:54.802699
140	46a51e5a-87d2-4a83-b24b-3f84162a8287	verification_result	FAILED	Verification output: 	1	2026-06-23 13:49:54.80997
141	46a51e5a-87d2-4a83-b24b-3f84162a8287	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:49:54.814066
142	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:50:04.831086
143	46a51e5a-87d2-4a83-b24b-3f84162a8287	retry_attempt	FAILED	Attempt 2 failed	1	2026-06-23 13:50:14.86483
144	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_validating	VALIDATING	Validation started	0	2026-06-23 13:50:14.88678
145	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_running	RUNNING	Execution started	0	2026-06-23 13:50:24.897401
146	46a51e5a-87d2-4a83-b24b-3f84162a8287	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-23 13:50:39.914935
147	46a51e5a-87d2-4a83-b24b-3f84162a8287	verification_result	FAILED	Verification output: 	1	2026-06-23 13:50:39.921029
148	46a51e5a-87d2-4a83-b24b-3f84162a8287	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-23 13:50:39.928036
149	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_verifying	VERIFYING	Verification started	0	2026-06-23 13:50:49.939339
150	46a51e5a-87d2-4a83-b24b-3f84162a8287	retry_attempt	FAILED	Attempt 3 failed	1	2026-06-23 13:50:59.958205
151	46a51e5a-87d2-4a83-b24b-3f84162a8287	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-06-23 13:50:59.966505
152	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	job_received	SUCCESS	Job request accepted and stored	0	2026-06-24 12:37:36.168005
153	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	status_validating	VALIDATING	Validation started	0	2026-06-24 12:37:45.391303
154	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	status_running	RUNNING	Execution started	0	2026-06-24 12:37:55.417713
155	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=1.47s; stdout=VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 18 2023 09:20:34)\nIncluded patches: 1-1453, 3625, 3669, 3741\nModified by pkg-vim-maintainers@lists.alioth.debian.org\nCompiled by pkg-vim-maintainers@lists.alioth.debian.org\nHuge version without GUI.  Features included (+) or not (-):\n+acl             ; stderr=	0	2026-06-24 12:38:11.904802
156	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	verification_result	SUCCESS	Verification output: VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 18 2023 09:20:34)\nIncluded patches: 1-1453, 3625, 3669, 3741\nModified by pkg-vim-maintainers@lists.alioth.debian.org\nCompiled by pkg-vim-maintainers@lists.alioth.debian.org\nHuge version without GUI.  Features included (+) or not (-):\n+acl               +farsi             +mouse_sgr         -tag_any_white\n+arabic            +file_in_path      -mouse_sysmouse    -tcl\n+autocmd           +find_in_path      +mouse_urxvt       +termguicolors\n-autoservername    +float             +mouse_xterm       +terminal\n-balloon_eval      +folding           +multi_byte        +terminfo\n+balloon_eval_term -footer            +multi_lang        +termresponse\n-browse            +fork()            -mzscheme          +textobjects\n++builtin_terms    +gettext           +netbeans_intg     +timers\n+byte_offset       -hangul_input      +num64             +title\n+channel           +iconv             +packages          -toolbar\n+cindent           +insert_expand     +path_extra        +user_commands\n-clientserver      +job               -perl              +vertsplit\n-clipboard         +jumplist          +persistent_undo   +virtualedit\n+cmdline_compl     +keymap            +postscript        +visual\n+cmdline_hist      +lambda            +printer           +visualextra\n+cmdline_info      +langmap           +profile           +viminfo\n+comments          +libcall           -python            +vreplace\n+conceal           +linebreak         +python3           +wildignore\n+cryptv            +lispindent        +quickfix          +wildmenu\n+cscope            +listcmds          +reltime           +windows\n+cursorbind        +localmap          +rightleft         +writebackup\n+cursorshape       -lua               -ruby              -X11\n+dialog_con        +menu              +scrollbind        -xfontset\n+diff              +mksession         +signs             -xim\n+digraphs          +modify_fname      +smartindent       -xpm\n-dnd               +mouse             +startuptime       -xsmp\n-ebcdic            -mouseshape        +statusline        -xterm_clipboard\n+emacs_tags        +mouse_dec         -sun_workshop      -xterm_save\n+eval              +mouse_gpm         +syntax            \n+ex_extra          -mouse_jsbterm     +tag_binary        \n+extra_search      +mouse_netterm     +tag_old_static    \n   system vimrc file: "$VIM/vimrc"\n     user vimrc file: "$HOME/.vimrc"\n 2nd user vimrc file: "~/.vim/vimrc"\n      user exrc file: "$HOME/.exrc"\n       defaults file: "$VIMRUNTIME/defaults.vim"\n  fall-back for $VIM: "/usr/share/vim"\nCompilation: gcc -c -I. -Iproto -DHAVE_CONFIG_H   -Wdate-time  -g -O2 -fdebug-prefix-map=/build/vim-bW1j6S/vim-8.0.1453=. -fstack-protector-strong -Wformat -Werror=format-security -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1       \nLinking: gcc   -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -o vim        -lm -ltinfo -lnsl  -lselinux  -lacl -lattr -lgpm -ldl     -L/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu -lpython3.6m -lpthread -ldl -lutil -lm      \n	0	2026-06-24 12:38:11.914612
157	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	execution_time	SUCCESS	Execution took 1.48 seconds	0	2026-06-24 12:38:11.924389
158	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	status_verifying	VERIFYING	Verification started	0	2026-06-24 12:38:21.938964
159	6ee800e6-01bc-47ce-8da9-6c3d6f49538c	status_success	SUCCESS	Execution completed successfully	0	2026-06-24 12:38:31.956441
160	6602d431-20fc-4ea4-b3a5-4f3c16dca762	job_received	SUCCESS	Job request accepted and stored	0	2026-06-24 12:44:53.509914
161	6602d431-20fc-4ea4-b3a5-4f3c16dca762	status_validating	VALIDATING	Validation started	0	2026-06-24 12:45:00.749982
162	6602d431-20fc-4ea4-b3a5-4f3c16dca762	status_running	RUNNING	Execution started	0	2026-06-24 12:45:10.769878
218	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_validating	VALIDATING	Validation started	0	2026-07-29 10:07:43.362979
163	6602d431-20fc-4ea4-b3a5-4f3c16dca762	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=1.09s; stdout=VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 18 2023 09:20:34)\nIncluded patches: 1-1453, 3625, 3669, 3741\nModified by pkg-vim-maintainers@lists.alioth.debian.org\nCompiled by pkg-vim-maintainers@lists.alioth.debian.org\nHuge version without GUI.  Features included (+) or not (-):\n+acl             ; stderr=	0	2026-06-24 12:45:26.902271
165	6602d431-20fc-4ea4-b3a5-4f3c16dca762	execution_time	SUCCESS	Execution took 1.09 seconds	0	2026-06-24 12:45:26.950123
167	6602d431-20fc-4ea4-b3a5-4f3c16dca762	status_success	SUCCESS	Execution completed successfully	0	2026-06-24 12:45:46.989478
169	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_validating	VALIDATING	Validation started	0	2026-06-24 12:46:25.870718
171	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-24 12:46:50.92395
173	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-24 12:46:50.996866
176	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_validating	VALIDATING	Validation started	0	2026-06-24 12:47:11.106769
178	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-24 12:47:36.151781
180	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-24 12:47:36.177286
183	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_validating	VALIDATING	Validation started	0	2026-06-24 12:47:56.283605
185	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	execution_result	FAILED	transport=winrm; exit_code=1; duration=0.0s; stdout=; stderr=auth method ntlm requires a username	1	2026-06-24 12:48:21.335333
187	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	execution_time	SUCCESS	Execution took 0.0 seconds	0	2026-06-24 12:48:21.353289
164	6602d431-20fc-4ea4-b3a5-4f3c16dca762	verification_result	SUCCESS	Verification output: VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Apr 18 2023 09:20:34)\nIncluded patches: 1-1453, 3625, 3669, 3741\nModified by pkg-vim-maintainers@lists.alioth.debian.org\nCompiled by pkg-vim-maintainers@lists.alioth.debian.org\nHuge version without GUI.  Features included (+) or not (-):\n+acl               +farsi             +mouse_sgr         -tag_any_white\n+arabic            +file_in_path      -mouse_sysmouse    -tcl\n+autocmd           +find_in_path      +mouse_urxvt       +termguicolors\n-autoservername    +float             +mouse_xterm       +terminal\n-balloon_eval      +folding           +multi_byte        +terminfo\n+balloon_eval_term -footer            +multi_lang        +termresponse\n-browse            +fork()            -mzscheme          +textobjects\n++builtin_terms    +gettext           +netbeans_intg     +timers\n+byte_offset       -hangul_input      +num64             +title\n+channel           +iconv             +packages          -toolbar\n+cindent           +insert_expand     +path_extra        +user_commands\n-clientserver      +job               -perl              +vertsplit\n-clipboard         +jumplist          +persistent_undo   +virtualedit\n+cmdline_compl     +keymap            +postscript        +visual\n+cmdline_hist      +lambda            +printer           +visualextra\n+cmdline_info      +langmap           +profile           +viminfo\n+comments          +libcall           -python            +vreplace\n+conceal           +linebreak         +python3           +wildignore\n+cryptv            +lispindent        +quickfix          +wildmenu\n+cscope            +listcmds          +reltime           +windows\n+cursorbind        +localmap          +rightleft         +writebackup\n+cursorshape       -lua               -ruby              -X11\n+dialog_con        +menu              +scrollbind        -xfontset\n+diff              +mksession         +signs             -xim\n+digraphs          +modify_fname      +smartindent       -xpm\n-dnd               +mouse             +startuptime       -xsmp\n-ebcdic            -mouseshape        +statusline        -xterm_clipboard\n+emacs_tags        +mouse_dec         -sun_workshop      -xterm_save\n+eval              +mouse_gpm         +syntax            \n+ex_extra          -mouse_jsbterm     +tag_binary        \n+extra_search      +mouse_netterm     +tag_old_static    \n   system vimrc file: "$VIM/vimrc"\n     user vimrc file: "$HOME/.vimrc"\n 2nd user vimrc file: "~/.vim/vimrc"\n      user exrc file: "$HOME/.exrc"\n       defaults file: "$VIMRUNTIME/defaults.vim"\n  fall-back for $VIM: "/usr/share/vim"\nCompilation: gcc -c -I. -Iproto -DHAVE_CONFIG_H   -Wdate-time  -g -O2 -fdebug-prefix-map=/build/vim-bW1j6S/vim-8.0.1453=. -fstack-protector-strong -Wformat -Werror=format-security -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1       \nLinking: gcc   -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -o vim        -lm -ltinfo -lnsl  -lselinux  -lacl -lattr -lgpm -ldl     -L/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu -lpython3.6m -lpthread -ldl -lutil -lm      \n	0	2026-06-24 12:45:26.934737
166	6602d431-20fc-4ea4-b3a5-4f3c16dca762	status_verifying	VERIFYING	Verification started	0	2026-06-24 12:45:36.965645
168	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	job_received	SUCCESS	Job request accepted and stored	0	2026-06-24 12:46:18.942566
170	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_running	RUNNING	Execution started	0	2026-06-24 12:46:35.906779
172	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	verification_result	FAILED	Verification output: 	1	2026-06-24 12:46:50.985011
174	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_verifying	VERIFYING	Verification started	0	2026-06-24 12:47:01.014045
175	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	retry_attempt	FAILED	Attempt 1 failed	1	2026-06-24 12:47:11.052941
177	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_running	RUNNING	Execution started	0	2026-06-24 12:47:21.136847
179	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	verification_result	FAILED	Verification output: 	1	2026-06-24 12:47:36.165094
181	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_verifying	VERIFYING	Verification started	0	2026-06-24 12:47:46.196404
182	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	retry_attempt	FAILED	Attempt 2 failed	1	2026-06-24 12:47:56.250076
184	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_running	RUNNING	Execution started	0	2026-06-24 12:48:06.301854
186	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	verification_result	FAILED	Verification output: 	1	2026-06-24 12:48:21.345813
188	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_verifying	VERIFYING	Verification started	0	2026-06-24 12:48:31.365279
189	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	retry_attempt	FAILED	Attempt 3 failed	1	2026-06-24 12:48:41.399564
190	2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-06-24 12:48:41.416921
191	c223baea-2c06-4aa5-b6cb-34b916340854	job_received	SUCCESS	Job request accepted and stored	0	2026-07-22 11:12:49.572878
192	cfaa06a9-a385-45ef-a39b-e6155cb83144	job_received	SUCCESS	Job request accepted and stored	0	2026-07-22 13:34:57.452311
193	24a08414-11d2-4a64-be59-550c557a0801	job_received	SUCCESS	Job request accepted and stored	0	2026-07-23 09:17:45.157898
194	7d1a4226-53ac-43f3-b969-953de4c2e648	job_received	SUCCESS	Job request accepted and stored	0	2026-07-23 09:18:00.115641
195	db6bc06e-e9ab-4304-b2d3-abc0d453e75d	job_received	SUCCESS	Job request accepted and stored	0	2026-07-29 09:07:19.209103
196	abd2db65-3e59-4cc2-a3ee-eb0e954c5a1c	job_received	SUCCESS	Job request accepted and stored	0	2026-07-29 09:23:42.831417
197	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	job_received	SUCCESS	Job request accepted and stored	0	2026-07-29 10:05:40.267543
198	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	job_queued	SUCCESS	Job queued to Celery. celery_task_id=e19b5868-63b5-4e01-9adc-1fc3a3d67d62	0	2026-07-29 10:06:12.735281
199	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=e19b5868-63b5-4e01-9adc-1fc3a3d67d62	0	2026-07-29 10:06:12.782027
200	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_validating	VALIDATING	Validation started	0	2026-07-29 10:06:12.793444
201	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_running	RUNNING	Execution started	0	2026-07-29 10:06:22.801784
202	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	execution_result	FAILED	transport=ssh; exit_code=100; duration=0.21s; stdout=; stderr=E: Unable to locate package vim\n	100	2026-07-29 10:06:38.039516
203	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	verification_result	FAILED	Verification output: 	100	2026-07-29 10:06:38.045457
204	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	execution_time	SUCCESS	Execution took 0.22 seconds	0	2026-07-29 10:06:38.053213
205	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_verifying	VERIFYING	Verification started	0	2026-07-29 10:06:48.057862
206	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	retry_attempt	FAILED	Attempt 1 failed	100	2026-07-29 10:06:58.068358
207	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=e19b5868-63b5-4e01-9adc-1fc3a3d67d62	0	2026-07-29 10:06:58.101353
208	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=3c54315e-1036-43ea-9ee1-b9c63f2833ec	0	2026-07-29 10:06:58.148922
209	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_validating	VALIDATING	Validation started	0	2026-07-29 10:06:58.157269
210	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_running	RUNNING	Execution started	0	2026-07-29 10:07:08.163344
211	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	execution_result	FAILED	transport=ssh; exit_code=100; duration=0.13s; stdout=; stderr=E: Unable to locate package vim\n	100	2026-07-29 10:07:23.308426
212	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	verification_result	FAILED	Verification output: 	100	2026-07-29 10:07:23.318401
213	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	execution_time	SUCCESS	Execution took 0.13 seconds	0	2026-07-29 10:07:23.323038
214	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_verifying	VERIFYING	Verification started	0	2026-07-29 10:07:33.330204
215	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	retry_attempt	FAILED	Attempt 2 failed	100	2026-07-29 10:07:43.336277
216	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=3c54315e-1036-43ea-9ee1-b9c63f2833ec	0	2026-07-29 10:07:43.355959
217	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=58bbf62b-03ea-4c9e-a181-d1a2d232cd80	0	2026-07-29 10:07:43.358817
219	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_running	RUNNING	Execution started	0	2026-07-29 10:07:53.368906
220	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	execution_result	FAILED	transport=ssh; exit_code=100; duration=0.11s; stdout=; stderr=E: Unable to locate package vim\n	100	2026-07-29 10:08:08.483375
221	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	verification_result	FAILED	Verification output: 	100	2026-07-29 10:08:08.487859
222	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	execution_time	SUCCESS	Execution took 0.11 seconds	0	2026-07-29 10:08:08.49052
223	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_verifying	VERIFYING	Verification started	0	2026-07-29 10:08:18.498753
224	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	retry_attempt	FAILED	Attempt 3 failed	100	2026-07-29 10:08:28.522786
225	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-07-29 10:08:28.534634
226	01153b27-ce1f-4ecd-8ea2-065b9ed0e948	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=58bbf62b-03ea-4c9e-a181-d1a2d232cd80	0	2026-07-29 10:08:28.546674
229	a258a959-57ac-4d52-b278-a81daae14be0	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=aef29512-ca1d-41b4-935a-6eb5f4f4a57a	0	2026-07-29 10:32:15.980528
230	a258a959-57ac-4d52-b278-a81daae14be0	status_validating	VALIDATING	Validation started	0	2026-07-29 10:32:15.987324
231	a258a959-57ac-4d52-b278-a81daae14be0	status_running	RUNNING	Execution started	0	2026-07-29 10:32:25.994425
232	a258a959-57ac-4d52-b278-a81daae14be0	execution_result	FAILED	transport=ssh; exit_code=100; duration=0.16s; stdout=; stderr=E: Unable to locate package vim\n	100	2026-07-29 10:32:41.162577
233	a258a959-57ac-4d52-b278-a81daae14be0	verification_result	FAILED	Verification output: 	100	2026-07-29 10:32:41.165957
234	a258a959-57ac-4d52-b278-a81daae14be0	execution_time	SUCCESS	Execution took 0.16 seconds	0	2026-07-29 10:32:41.168252
235	a258a959-57ac-4d52-b278-a81daae14be0	status_verifying	VERIFYING	Verification started	0	2026-07-29 10:32:51.173611
236	a258a959-57ac-4d52-b278-a81daae14be0	retry_attempt	FAILED	Attempt 1 failed	100	2026-07-29 10:33:01.19107
237	a258a959-57ac-4d52-b278-a81daae14be0	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=aef29512-ca1d-41b4-935a-6eb5f4f4a57a	0	2026-07-29 10:33:01.206564
247	a258a959-57ac-4d52-b278-a81daae14be0	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=4d058a5f-0a6c-40b4-8852-ee741128fe77	0	2026-07-29 10:33:46.410077
248	a258a959-57ac-4d52-b278-a81daae14be0	status_validating	VALIDATING	Validation started	0	2026-07-29 10:33:46.416054
249	a258a959-57ac-4d52-b278-a81daae14be0	status_running	RUNNING	Execution started	0	2026-07-29 10:33:56.423859
250	a258a959-57ac-4d52-b278-a81daae14be0	execution_result	FAILED	transport=ssh; exit_code=100; duration=0.15s; stdout=; stderr=E: Unable to locate package vim\n	100	2026-07-29 10:34:11.584217
251	a258a959-57ac-4d52-b278-a81daae14be0	verification_result	FAILED	Verification output: 	100	2026-07-29 10:34:11.589603
252	a258a959-57ac-4d52-b278-a81daae14be0	execution_time	SUCCESS	Execution took 0.15 seconds	0	2026-07-29 10:34:11.594887
253	a258a959-57ac-4d52-b278-a81daae14be0	status_verifying	VERIFYING	Verification started	0	2026-07-29 10:34:21.60181
254	a258a959-57ac-4d52-b278-a81daae14be0	retry_attempt	FAILED	Attempt 3 failed	100	2026-07-29 10:34:31.615739
255	a258a959-57ac-4d52-b278-a81daae14be0	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-07-29 10:34:31.623881
256	a258a959-57ac-4d52-b278-a81daae14be0	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=4d058a5f-0a6c-40b4-8852-ee741128fe77	0	2026-07-29 10:34:31.633028
260	532a0309-43e7-43c4-b6b2-f7d3bdb6a466	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=ddb53fa0-72c1-43a6-8295-a9383b51189f	0	2026-07-29 13:27:19.841956
261	532a0309-43e7-43c4-b6b2-f7d3bdb6a466	status_validating	VALIDATING	Validation started	0	2026-07-29 13:27:19.852582
262	532a0309-43e7-43c4-b6b2-f7d3bdb6a466	status_running	RUNNING	Execution started	0	2026-07-29 13:27:29.860655
227	a258a959-57ac-4d52-b278-a81daae14be0	job_received	SUCCESS	Job request accepted and stored	0	2026-07-29 10:32:03.895102
228	a258a959-57ac-4d52-b278-a81daae14be0	job_queued	SUCCESS	Job queued to Celery. celery_task_id=aef29512-ca1d-41b4-935a-6eb5f4f4a57a	0	2026-07-29 10:32:15.972431
257	9f58c752-dfc6-4125-8602-3ab735a20612	job_received	SUCCESS	Job request accepted and stored	0	2026-07-29 13:26:46.027343
258	532a0309-43e7-43c4-b6b2-f7d3bdb6a466	job_received	SUCCESS	Job request accepted and stored	0	2026-07-29 13:27:07.655302
259	532a0309-43e7-43c4-b6b2-f7d3bdb6a466	job_queued	SUCCESS	Job queued to Celery. celery_task_id=ddb53fa0-72c1-43a6-8295-a9383b51189f	0	2026-07-29 13:27:19.771837
238	a258a959-57ac-4d52-b278-a81daae14be0	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=e448e369-d034-4229-99da-4c76c53507d3	0	2026-07-29 10:33:01.214419
239	a258a959-57ac-4d52-b278-a81daae14be0	status_validating	VALIDATING	Validation started	0	2026-07-29 10:33:01.218728
240	a258a959-57ac-4d52-b278-a81daae14be0	status_running	RUNNING	Execution started	0	2026-07-29 10:33:11.223576
241	a258a959-57ac-4d52-b278-a81daae14be0	execution_result	FAILED	transport=ssh; exit_code=100; duration=0.12s; stdout=; stderr=E: Unable to locate package vim\n	100	2026-07-29 10:33:26.368378
242	a258a959-57ac-4d52-b278-a81daae14be0	verification_result	FAILED	Verification output: 	100	2026-07-29 10:33:26.373645
243	a258a959-57ac-4d52-b278-a81daae14be0	execution_time	SUCCESS	Execution took 0.12 seconds	0	2026-07-29 10:33:26.376594
244	a258a959-57ac-4d52-b278-a81daae14be0	status_verifying	VERIFYING	Verification started	0	2026-07-29 10:33:36.380096
245	a258a959-57ac-4d52-b278-a81daae14be0	retry_attempt	FAILED	Attempt 2 failed	100	2026-07-29 10:33:46.390134
246	a258a959-57ac-4d52-b278-a81daae14be0	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=e448e369-d034-4229-99da-4c76c53507d3	0	2026-07-29 10:33:46.407063
263	3d345319-8690-49ab-89b7-2a01df5d2b8a	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 10:10:17.263668
264	3d345319-8690-49ab-89b7-2a01df5d2b8a	job_queued	SUCCESS	Job queued to Celery. celery_task_id=898b9e36-4f99-46a6-9164-ef6e9e51cc5c	0	2026-08-17 10:12:23.783761
265	3d345319-8690-49ab-89b7-2a01df5d2b8a	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=898b9e36-4f99-46a6-9164-ef6e9e51cc5c	0	2026-08-17 10:12:23.845528
266	3d345319-8690-49ab-89b7-2a01df5d2b8a	status_validating	VALIDATING	Validation started	0	2026-08-17 10:12:23.855594
267	3d345319-8690-49ab-89b7-2a01df5d2b8a	status_running	RUNNING	Execution started	0	2026-08-17 10:12:33.866317
268	3d345319-8690-49ab-89b7-2a01df5d2b8a	status_failed	FAILED	Execution exception: Software 'git' not approved for os_type 'linux'	0	2026-08-17 10:12:48.90401
269	3d345319-8690-49ab-89b7-2a01df5d2b8a	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=898b9e36-4f99-46a6-9164-ef6e9e51cc5c	0	2026-08-17 10:12:48.907788
270	23a51c79-0d59-4958-a46b-67e0b020123b	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 10:20:51.761147
271	23a51c79-0d59-4958-a46b-67e0b020123b	job_queued	SUCCESS	Job queued to Celery. celery_task_id=f3548b28-a752-4abb-a7fa-2f94341a32fc	0	2026-08-17 10:20:59.129941
272	23a51c79-0d59-4958-a46b-67e0b020123b	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=f3548b28-a752-4abb-a7fa-2f94341a32fc	0	2026-08-17 10:20:59.139646
273	23a51c79-0d59-4958-a46b-67e0b020123b	status_validating	VALIDATING	Validation started	0	2026-08-17 10:20:59.145957
274	23a51c79-0d59-4958-a46b-67e0b020123b	status_running	RUNNING	Execution started	0	2026-08-17 10:21:09.15165
275	23a51c79-0d59-4958-a46b-67e0b020123b	status_failed	FAILED	Execution exception: [Errno None] Unable to connect to port 22 on 192.168.65.254	0	2026-08-17 10:21:24.195985
276	23a51c79-0d59-4958-a46b-67e0b020123b	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=f3548b28-a752-4abb-a7fa-2f94341a32fc	0	2026-08-17 10:21:24.205511
277	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 10:22:00.583636
278	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	job_queued	SUCCESS	Job queued to Celery. celery_task_id=db3d62fe-cd9b-4220-ada0-be0f73978c9b	0	2026-08-17 10:22:04.342666
279	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=db3d62fe-cd9b-4220-ada0-be0f73978c9b	0	2026-08-17 10:22:04.349761
280	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	status_validating	VALIDATING	Validation started	0	2026-08-17 10:22:04.355499
281	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	status_running	RUNNING	Execution started	0	2026-08-17 10:22:14.362302
282	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	status_failed	FAILED	Execution exception: [Errno None] Unable to connect to port 22 on 192.168.65.254	0	2026-08-17 10:22:29.397837
283	3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=db3d62fe-cd9b-4220-ada0-be0f73978c9b	0	2026-08-17 10:22:29.402971
284	b8f6e288-7ba4-450e-a733-1932a87bc23a	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 11:13:48.049271
285	b8f6e288-7ba4-450e-a733-1932a87bc23a	job_queued	SUCCESS	Job queued to Celery. celery_task_id=c5cbfd62-fe4e-4532-8cde-696e2570cc52	0	2026-08-17 11:13:57.025088
286	b8f6e288-7ba4-450e-a733-1932a87bc23a	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=c5cbfd62-fe4e-4532-8cde-696e2570cc52	0	2026-08-17 11:13:57.064549
287	b8f6e288-7ba4-450e-a733-1932a87bc23a	status_validating	VALIDATING	Validation started	0	2026-08-17 11:13:57.073645
288	b8f6e288-7ba4-450e-a733-1932a87bc23a	status_running	RUNNING	Execution started	0	2026-08-17 11:14:07.08187
289	b8f6e288-7ba4-450e-a733-1932a87bc23a	status_failed	FAILED	Execution exception: [Errno None] Unable to connect to port 22 on 192.168.65.254	0	2026-08-17 11:14:22.124512
290	b8f6e288-7ba4-450e-a733-1932a87bc23a	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=c5cbfd62-fe4e-4532-8cde-696e2570cc52	0	2026-08-17 11:14:22.132005
291	90a78291-d3d8-4697-ad5e-a5787b8bd9a5	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 11:34:30.031857
292	90a78291-d3d8-4697-ad5e-a5787b8bd9a5	job_queued	SUCCESS	Job queued to Celery. celery_task_id=9ff7515f-1d62-4464-bc44-5af6495870bf	0	2026-08-17 11:34:53.509726
293	90a78291-d3d8-4697-ad5e-a5787b8bd9a5	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=9ff7515f-1d62-4464-bc44-5af6495870bf	0	2026-08-17 11:34:53.553533
294	90a78291-d3d8-4697-ad5e-a5787b8bd9a5	status_validating	VALIDATING	Validation started	0	2026-08-17 11:34:53.564485
295	90a78291-d3d8-4697-ad5e-a5787b8bd9a5	status_running	RUNNING	Execution started	0	2026-08-17 11:35:03.576783
296	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 12:11:29.5653
297	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	job_queued	SUCCESS	Job queued to Celery. celery_task_id=0e252118-a412-4ffa-8583-04a196de53f7	0	2026-08-17 12:11:36.886037
298	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=0e252118-a412-4ffa-8583-04a196de53f7	0	2026-08-17 12:11:37.059281
299	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_validating	VALIDATING	Validation started	0	2026-08-17 12:11:37.073993
300	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_running	RUNNING	Execution started	0	2026-08-17 12:11:47.087883
301	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	execution_result	FAILED	transport=ssh; exit_code=100; duration=2.5s; stdout=; stderr=E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)\nE: Unable to lock the administration directory (/var/lib/dpkg/), is another process using it?\n	100	2026-08-17 12:12:04.603923
302	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	verification_result	FAILED	Verification output: 	100	2026-08-17 12:12:04.609904
303	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	execution_time	SUCCESS	Execution took 2.5 seconds	0	2026-08-17 12:12:04.612871
304	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_verifying	VERIFYING	Verification started	0	2026-08-17 12:12:14.617079
305	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	retry_attempt	FAILED	Attempt 1 failed	100	2026-08-17 12:12:24.627775
306	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=0e252118-a412-4ffa-8583-04a196de53f7	0	2026-08-17 12:12:24.661934
307	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=5522abb3-fa1f-46e8-b19c-7925223f405d	0	2026-08-17 12:12:24.768092
308	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_validating	VALIDATING	Validation started	0	2026-08-17 12:12:24.778628
310	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_running	RUNNING	Execution started	0	2026-08-17 12:12:34.786119
312	3f1f87c3-501d-481d-9f2c-29675e4f3df8	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=9477538a-d545-4ed1-83f0-f739d464391e	0	2026-08-17 12:12:36.993859
313	3f1f87c3-501d-481d-9f2c-29675e4f3df8	status_validating	VALIDATING	Validation started	0	2026-08-17 12:12:37.001552
314	3f1f87c3-501d-481d-9f2c-29675e4f3df8	status_running	RUNNING	Execution started	0	2026-08-17 12:12:47.015521
315	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	execution_result	FAILED	transport=ssh; exit_code=100; duration=2.73s; stdout=; stderr=E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)\nE: Unable to lock the administration directory (/var/lib/dpkg/), is another process using it?\n	100	2026-08-17 12:12:52.533943
316	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	verification_result	FAILED	Verification output: 	100	2026-08-17 12:12:52.55253
317	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	execution_time	SUCCESS	Execution took 2.74 seconds	0	2026-08-17 12:12:52.559254
318	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_verifying	VERIFYING	Verification started	0	2026-08-17 12:13:02.569019
319	3f1f87c3-501d-481d-9f2c-29675e4f3df8	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=5.07s; stdout=/usr/bin/curl\n; stderr=	0	2026-08-17 12:13:07.096882
320	3f1f87c3-501d-481d-9f2c-29675e4f3df8	verification_result	SUCCESS	Verification output: /usr/bin/curl\n	0	2026-08-17 12:13:07.102843
321	3f1f87c3-501d-481d-9f2c-29675e4f3df8	execution_time	SUCCESS	Execution took 5.08 seconds	0	2026-08-17 12:13:07.106644
322	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	retry_attempt	FAILED	Attempt 2 failed	100	2026-08-17 12:13:12.609337
323	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=5522abb3-fa1f-46e8-b19c-7925223f405d	0	2026-08-17 12:13:12.655588
326	3f1f87c3-501d-481d-9f2c-29675e4f3df8	status_verifying	VERIFYING	Verification started	0	2026-08-17 12:13:17.116208
328	3f1f87c3-501d-481d-9f2c-29675e4f3df8	status_success	SUCCESS	Execution completed successfully	0	2026-08-17 12:13:27.128462
329	3f1f87c3-501d-481d-9f2c-29675e4f3df8	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=9477538a-d545-4ed1-83f0-f739d464391e	0	2026-08-17 12:13:27.137907
309	3f1f87c3-501d-481d-9f2c-29675e4f3df8	job_received	SUCCESS	Job request accepted and stored	0	2026-08-17 12:12:34.699459
311	3f1f87c3-501d-481d-9f2c-29675e4f3df8	job_queued	SUCCESS	Job queued to Celery. celery_task_id=9477538a-d545-4ed1-83f0-f739d464391e	0	2026-08-17 12:12:36.976316
324	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=4b23cfb9-16fe-4c39-aae7-390aaf16a46e	0	2026-08-17 12:13:12.767406
325	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_validating	VALIDATING	Validation started	0	2026-08-17 12:13:12.779363
327	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_running	RUNNING	Execution started	0	2026-08-17 12:13:22.789947
330	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	execution_result	FAILED	transport=ssh; exit_code=100; duration=1.89s; stdout=; stderr=E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)\nE: Unable to lock the administration directory (/var/lib/dpkg/), is another process using it?\n	100	2026-08-17 12:13:39.690064
331	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	verification_result	FAILED	Verification output: 	100	2026-08-17 12:13:39.695674
332	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	execution_time	SUCCESS	Execution took 1.89 seconds	0	2026-08-17 12:13:39.698921
333	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_verifying	VERIFYING	Verification started	0	2026-08-17 12:13:49.704884
334	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	retry_attempt	FAILED	Attempt 3 failed	100	2026-08-17 12:13:59.731722
335	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-08-17 12:13:59.73588
336	a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=4b23cfb9-16fe-4c39-aae7-390aaf16a46e	0	2026-08-17 12:13:59.74127
337	13a6f3cd-3c72-4900-a649-d0764220c4f3	job_received	SUCCESS	Job request accepted and stored	0	2026-08-28 10:51:19.728372
338	ccb52173-d97b-4ea0-b45a-d72629a403e4	job_received	SUCCESS	Job request accepted and stored	0	2026-08-28 11:24:16.148874
339	ccb52173-d97b-4ea0-b45a-d72629a403e4	job_queued	SUCCESS	Job queued to Celery. celery_task_id=19f79e6d-23f9-4a57-a344-ed5a41aa60b5	0	2026-08-28 11:24:20.662375
340	ccb52173-d97b-4ea0-b45a-d72629a403e4	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=19f79e6d-23f9-4a57-a344-ed5a41aa60b5	0	2026-08-28 11:24:20.722826
341	ccb52173-d97b-4ea0-b45a-d72629a403e4	status_validating	VALIDATING	Validation started	0	2026-08-28 11:24:20.73261
342	ccb52173-d97b-4ea0-b45a-d72629a403e4	status_running	RUNNING	Execution started	0	2026-08-28 11:24:30.740945
343	ccb52173-d97b-4ea0-b45a-d72629a403e4	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=5.32s; stdout=/usr/bin/curl\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-08-28 11:24:51.085346
344	ccb52173-d97b-4ea0-b45a-d72629a403e4	verification_result	SUCCESS	Verification output: /usr/bin/curl\n	0	2026-08-28 11:24:51.091536
345	ccb52173-d97b-4ea0-b45a-d72629a403e4	execution_time	SUCCESS	Execution took 5.32 seconds	0	2026-08-28 11:24:51.093945
346	ccb52173-d97b-4ea0-b45a-d72629a403e4	status_verifying	VERIFYING	Verification started	0	2026-08-28 11:25:01.103358
347	ccb52173-d97b-4ea0-b45a-d72629a403e4	status_success	SUCCESS	Execution completed successfully	0	2026-08-28 11:25:11.113031
348	ccb52173-d97b-4ea0-b45a-d72629a403e4	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=19f79e6d-23f9-4a57-a344-ed5a41aa60b5	0	2026-08-28 11:25:11.120334
349	d1544238-c3c4-4ae9-a114-038e3aff67bc	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 13:53:31.781366
350	d1544238-c3c4-4ae9-a114-038e3aff67bc	job_auto_queued	SUCCESS	ServiceNow request auto-queued. celery_task_id=af4058d7-b934-40ba-b1d1-0313c4f39455	0	2026-08-30 13:53:31.919196
351	d1544238-c3c4-4ae9-a114-038e3aff67bc	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=af4058d7-b934-40ba-b1d1-0313c4f39455	0	2026-08-30 13:53:31.975809
352	d1544238-c3c4-4ae9-a114-038e3aff67bc	status_validating	VALIDATING	Validation started	0	2026-08-30 13:53:31.985769
353	d1544238-c3c4-4ae9-a114-038e3aff67bc	status_running	RUNNING	Execution started	0	2026-08-30 13:53:41.992414
354	d1544238-c3c4-4ae9-a114-038e3aff67bc	status_failed	FAILED	Execution exception: Software 'git' not approved for os_type 'linux'	0	2026-08-30 13:53:57.012747
355	d1544238-c3c4-4ae9-a114-038e3aff67bc	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=af4058d7-b934-40ba-b1d1-0313c4f39455	0	2026-08-30 13:53:57.018136
356	2c134a82-9ea2-483e-9c8c-790506c677ad	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 13:57:55.136551
357	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:08:47.367585
358	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	job_auto_queued	SUCCESS	ServiceNow request auto-queued. celery_task_id=76e50bca-e620-43ef-b64a-4f68606dcb82	0	2026-08-30 14:08:47.373769
359	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=76e50bca-e620-43ef-b64a-4f68606dcb82	0	2026-08-30 14:08:47.379309
360	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	status_validating	VALIDATING	Validation started	0	2026-08-30 14:08:47.383885
361	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	status_running	RUNNING	Execution started	0	2026-08-30 14:08:57.389525
362	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=6.92s; stdout=/usr/bin/vim\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-08-30 14:09:19.314631
363	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	verification_result	SUCCESS	Verification output: /usr/bin/vim\n	0	2026-08-30 14:09:19.319754
364	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	execution_time	SUCCESS	Execution took 6.92 seconds	0	2026-08-30 14:09:19.32282
365	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	status_verifying	VERIFYING	Verification started	0	2026-08-30 14:09:29.330317
366	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	status_success	SUCCESS	Execution completed successfully	0	2026-08-30 14:09:39.339352
367	d09eaf89-52e6-4df0-a0b8-6f44ea996de9	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=76e50bca-e620-43ef-b64a-4f68606dcb82	0	2026-08-30 14:09:39.350793
368	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:17:59.068238
369	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	job_queued	SUCCESS	Job queued to Celery. celery_task_id=f024b58d-2fd7-47ac-9a57-eddf1d162243	0	2026-08-30 14:20:04.810664
370	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=f024b58d-2fd7-47ac-9a57-eddf1d162243	0	2026-08-30 14:20:04.818494
371	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	status_validating	VALIDATING	Validation started	0	2026-08-30 14:20:04.824947
372	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	status_running	RUNNING	Execution started	0	2026-08-30 14:20:14.830614
373	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=14.72s; stdout=/usr/bin/curl\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-08-30 14:20:44.558905
374	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	verification_result	SUCCESS	Verification output: /usr/bin/curl\n	0	2026-08-30 14:20:44.56273
375	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	execution_time	SUCCESS	Execution took 14.72 seconds	0	2026-08-30 14:20:44.566623
376	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	status_verifying	VERIFYING	Verification started	0	2026-08-30 14:20:54.57348
377	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	status_success	SUCCESS	Execution completed successfully	0	2026-08-30 14:21:04.580997
378	f2e52d0d-9755-4a6a-b949-db8a7fa6bded	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=f024b58d-2fd7-47ac-9a57-eddf1d162243	0	2026-08-30 14:21:04.60293
379	a7de03cb-9545-453c-9ef6-36a861ddd509	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:36:32.445361
380	fabcf2a8-1b80-4dc3-a53e-33339cd66c18	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:39:38.192617
381	2123c253-287d-4fdd-bf72-f48871682f3f	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:40:08.313448
382	5ca70672-caac-4008-be0f-ebec84e9072f	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:42:43.484393
383	5ca70672-caac-4008-be0f-ebec84e9072f	job_auto_queued	SUCCESS	ServiceNow request auto-queued. celery_task_id=94d79546-41db-4893-90e0-7508b10ba318	0	2026-08-30 14:42:43.555158
384	5ca70672-caac-4008-be0f-ebec84e9072f	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=94d79546-41db-4893-90e0-7508b10ba318	0	2026-08-30 14:42:43.620886
385	5ca70672-caac-4008-be0f-ebec84e9072f	status_validating	VALIDATING	Validation started	0	2026-08-30 14:42:43.634195
386	5ca70672-caac-4008-be0f-ebec84e9072f	status_running	RUNNING	Execution started	0	2026-08-30 14:42:53.639328
387	5ca70672-caac-4008-be0f-ebec84e9072f	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=20.27s; stdout=git version 2.17.1\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-08-30 14:43:28.935263
388	5ca70672-caac-4008-be0f-ebec84e9072f	verification_result	SUCCESS	Verification output: git version 2.17.1\n	0	2026-08-30 14:43:28.940148
389	5ca70672-caac-4008-be0f-ebec84e9072f	execution_time	SUCCESS	Execution took 20.27 seconds	0	2026-08-30 14:43:28.942584
390	5ca70672-caac-4008-be0f-ebec84e9072f	status_verifying	VERIFYING	Verification started	0	2026-08-30 14:43:38.953231
391	5ca70672-caac-4008-be0f-ebec84e9072f	status_success	SUCCESS	Execution completed successfully	0	2026-08-30 14:43:48.972828
392	5ca70672-caac-4008-be0f-ebec84e9072f	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=94d79546-41db-4893-90e0-7508b10ba318	0	2026-08-30 14:43:48.979372
393	7bd02baf-ce5a-4826-92a6-dbe24419c271	job_received	SUCCESS	Job request accepted and stored	0	2026-08-30 14:44:25.752584
394	7bd02baf-ce5a-4826-92a6-dbe24419c271	job_queued	SUCCESS	Job queued to Celery. celery_task_id=c241bc7c-89d1-4160-9cbf-9a7a14ce1f67	0	2026-08-30 14:46:05.567143
395	7bd02baf-ce5a-4826-92a6-dbe24419c271	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=c241bc7c-89d1-4160-9cbf-9a7a14ce1f67	0	2026-08-30 14:46:05.5796
396	7bd02baf-ce5a-4826-92a6-dbe24419c271	status_validating	VALIDATING	Validation started	0	2026-08-30 14:46:05.587272
397	7bd02baf-ce5a-4826-92a6-dbe24419c271	status_running	RUNNING	Execution started	0	2026-08-30 14:46:15.591218
398	7bd02baf-ce5a-4826-92a6-dbe24419c271	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=5.35s; stdout=/usr/bin/vim\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-08-30 14:46:35.949241
399	7bd02baf-ce5a-4826-92a6-dbe24419c271	verification_result	SUCCESS	Verification output: /usr/bin/vim\n	0	2026-08-30 14:46:35.953283
400	7bd02baf-ce5a-4826-92a6-dbe24419c271	execution_time	SUCCESS	Execution took 5.35 seconds	0	2026-08-30 14:46:35.955622
401	7bd02baf-ce5a-4826-92a6-dbe24419c271	status_verifying	VERIFYING	Verification started	0	2026-08-30 14:46:45.960129
402	7bd02baf-ce5a-4826-92a6-dbe24419c271	status_success	SUCCESS	Execution completed successfully	0	2026-08-30 14:46:55.972714
403	7bd02baf-ce5a-4826-92a6-dbe24419c271	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=c241bc7c-89d1-4160-9cbf-9a7a14ce1f67	0	2026-08-30 14:46:55.99615
404	7e5d8179-9920-4b00-a382-06aa0964a61b	job_received	SUCCESS	Job request accepted and stored	0	2026-08-31 09:15:50.055163
405	6234cd22-e8c9-4603-8643-5e97b3476d78	job_received	SUCCESS	Job request accepted and stored	0	2026-08-31 09:19:56.231669
406	265be063-69d5-4a0c-a2ea-4e43d876e80d	job_received	SUCCESS	Job request accepted and stored	0	2026-08-31 09:23:32.762192
407	265be063-69d5-4a0c-a2ea-4e43d876e80d	job_queued	SUCCESS	Job queued to Celery. celery_task_id=b5c616a0-f69b-4b68-88da-1d6c0b36e54c	0	2026-08-31 09:24:28.534725
408	265be063-69d5-4a0c-a2ea-4e43d876e80d	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=b5c616a0-f69b-4b68-88da-1d6c0b36e54c	0	2026-08-31 09:24:28.781104
409	265be063-69d5-4a0c-a2ea-4e43d876e80d	status_validating	VALIDATING	Validation started	0	2026-08-31 09:24:28.810729
410	265be063-69d5-4a0c-a2ea-4e43d876e80d	status_running	RUNNING	Execution started	0	2026-08-31 09:24:38.829403
411	265be063-69d5-4a0c-a2ea-4e43d876e80d	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=9.24s; stdout=/usr/bin/curl\n; stderr=debconf: delaying package configuration, since apt-utils is not installed\n	0	2026-08-31 09:25:03.081338
412	265be063-69d5-4a0c-a2ea-4e43d876e80d	verification_result	SUCCESS	Verification output: /usr/bin/curl\n	0	2026-08-31 09:25:03.088737
413	265be063-69d5-4a0c-a2ea-4e43d876e80d	execution_time	SUCCESS	Execution took 9.25 seconds	0	2026-08-31 09:25:03.093087
414	265be063-69d5-4a0c-a2ea-4e43d876e80d	status_verifying	VERIFYING	Verification started	0	2026-08-31 09:25:13.120805
415	265be063-69d5-4a0c-a2ea-4e43d876e80d	status_success	SUCCESS	Execution completed successfully	0	2026-08-31 09:25:23.131171
416	265be063-69d5-4a0c-a2ea-4e43d876e80d	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=b5c616a0-f69b-4b68-88da-1d6c0b36e54c	0	2026-08-31 09:25:23.160265
417	0b742fe1-4149-45e6-8dc3-b4b342e433db	job_received	SUCCESS	Job request accepted and stored	0	2026-09-01 07:21:01.004895
418	0b742fe1-4149-45e6-8dc3-b4b342e433db	job_queued	SUCCESS	Job queued to Celery. celery_task_id=df24287a-c02c-48e9-bd5c-f3e0d3152123	0	2026-09-01 07:23:41.072741
419	0b742fe1-4149-45e6-8dc3-b4b342e433db	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=df24287a-c02c-48e9-bd5c-f3e0d3152123	0	2026-09-01 07:23:41.116451
420	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_validating	VALIDATING	Validation started	0	2026-09-01 07:23:41.124148
421	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_running	RUNNING	Execution started	0	2026-09-01 07:23:51.128802
422	0b742fe1-4149-45e6-8dc3-b4b342e433db	execution_result	FAILED	transport=ssh; exit_code=-1; duration=0.01s; stdout=; stderr=[Errno None] Unable to connect to port 2221 on 192.168.65.254	-1	2026-09-01 07:24:06.141699
423	0b742fe1-4149-45e6-8dc3-b4b342e433db	verification_result	FAILED	Verification output: 	-1	2026-09-01 07:24:06.146917
424	0b742fe1-4149-45e6-8dc3-b4b342e433db	execution_time	SUCCESS	Execution took 0.01 seconds	0	2026-09-01 07:24:06.149593
425	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_verifying	VERIFYING	Verification started	0	2026-09-01 07:24:16.167956
426	0b742fe1-4149-45e6-8dc3-b4b342e433db	retry_attempt	FAILED	Attempt 1 failed	-1	2026-09-01 07:24:26.198724
427	0b742fe1-4149-45e6-8dc3-b4b342e433db	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=df24287a-c02c-48e9-bd5c-f3e0d3152123	0	2026-09-01 07:24:26.219544
428	0b742fe1-4149-45e6-8dc3-b4b342e433db	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=518773e0-585e-41d0-b628-703b827b016a	0	2026-09-01 07:24:26.256356
429	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_validating	VALIDATING	Validation started	0	2026-09-01 07:24:26.264005
430	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_running	RUNNING	Execution started	0	2026-09-01 07:24:36.27176
431	0b742fe1-4149-45e6-8dc3-b4b342e433db	execution_result	FAILED	transport=ssh; exit_code=-1; duration=0.01s; stdout=; stderr=[Errno None] Unable to connect to port 2221 on 192.168.65.254	-1	2026-09-01 07:24:51.282457
432	0b742fe1-4149-45e6-8dc3-b4b342e433db	verification_result	FAILED	Verification output: 	-1	2026-09-01 07:24:51.286199
433	0b742fe1-4149-45e6-8dc3-b4b342e433db	execution_time	SUCCESS	Execution took 0.01 seconds	0	2026-09-01 07:24:51.288505
434	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_verifying	VERIFYING	Verification started	0	2026-09-01 07:25:01.306347
435	0b742fe1-4149-45e6-8dc3-b4b342e433db	retry_attempt	FAILED	Attempt 2 failed	-1	2026-09-01 07:25:11.322985
436	0b742fe1-4149-45e6-8dc3-b4b342e433db	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=518773e0-585e-41d0-b628-703b827b016a	0	2026-09-01 07:25:11.348208
437	0b742fe1-4149-45e6-8dc3-b4b342e433db	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=cc0c705a-bc4c-4b3d-8b7f-8610f971a080	0	2026-09-01 07:25:11.351988
438	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_validating	VALIDATING	Validation started	0	2026-09-01 07:25:11.356615
439	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_running	RUNNING	Execution started	0	2026-09-01 07:25:21.36458
440	6fc1dff3-5f11-42a1-b308-a0343702a9ee	job_received	SUCCESS	Job request accepted and stored	0	2026-09-01 07:25:34.221646
441	0b742fe1-4149-45e6-8dc3-b4b342e433db	execution_result	FAILED	transport=ssh; exit_code=-1; duration=0.02s; stdout=; stderr=[Errno None] Unable to connect to port 2221 on 192.168.65.254	-1	2026-09-01 07:25:36.392171
442	0b742fe1-4149-45e6-8dc3-b4b342e433db	verification_result	FAILED	Verification output: 	-1	2026-09-01 07:25:36.395981
443	0b742fe1-4149-45e6-8dc3-b4b342e433db	execution_time	SUCCESS	Execution took 0.02 seconds	0	2026-09-01 07:25:36.399003
444	6fc1dff3-5f11-42a1-b308-a0343702a9ee	job_queued	SUCCESS	Job queued to Celery. celery_task_id=c1affaf9-4a9b-44bd-8408-86b45865d235	0	2026-09-01 07:25:42.085273
445	6fc1dff3-5f11-42a1-b308-a0343702a9ee	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=c1affaf9-4a9b-44bd-8408-86b45865d235	0	2026-09-01 07:25:42.092691
446	6fc1dff3-5f11-42a1-b308-a0343702a9ee	status_validating	VALIDATING	Validation started	0	2026-09-01 07:25:42.098599
447	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_verifying	VERIFYING	Verification started	0	2026-09-01 07:25:46.408657
448	6fc1dff3-5f11-42a1-b308-a0343702a9ee	status_running	RUNNING	Execution started	0	2026-09-01 07:25:52.101045
449	0b742fe1-4149-45e6-8dc3-b4b342e433db	retry_attempt	FAILED	Attempt 3 failed	-1	2026-09-01 07:25:56.419601
450	0b742fe1-4149-45e6-8dc3-b4b342e433db	status_failed_final	FAILED_FINAL	Execution failed after 3 attempts	0	2026-09-01 07:25:56.422856
451	0b742fe1-4149-45e6-8dc3-b4b342e433db	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=cc0c705a-bc4c-4b3d-8b7f-8610f971a080	0	2026-09-01 07:25:56.426703
452	6fc1dff3-5f11-42a1-b308-a0343702a9ee	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=3.12s; stdout=/usr/bin/vim\n; stderr=	0	2026-09-01 07:26:10.225265
453	6fc1dff3-5f11-42a1-b308-a0343702a9ee	verification_result	SUCCESS	Verification output: /usr/bin/vim\n	0	2026-09-01 07:26:10.22865
454	6fc1dff3-5f11-42a1-b308-a0343702a9ee	execution_time	SUCCESS	Execution took 3.12 seconds	0	2026-09-01 07:26:10.230963
455	6fc1dff3-5f11-42a1-b308-a0343702a9ee	status_verifying	VERIFYING	Verification started	0	2026-09-01 07:26:20.241196
456	6fc1dff3-5f11-42a1-b308-a0343702a9ee	status_success	SUCCESS	Execution completed successfully	0	2026-09-01 07:26:30.253691
457	6fc1dff3-5f11-42a1-b308-a0343702a9ee	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=c1affaf9-4a9b-44bd-8408-86b45865d235	0	2026-09-01 07:26:30.264211
458	34658c01-57c9-40a7-b2a7-b3036347fafc	job_received	SUCCESS	Job request accepted and stored	0	2026-09-01 10:13:48.546194
459	34658c01-57c9-40a7-b2a7-b3036347fafc	job_auto_queued	SUCCESS	ServiceNow request auto-queued. celery_task_id=6fa2d194-8bb3-4b4d-82ea-b7601584bf73	0	2026-09-01 10:13:48.8572
460	34658c01-57c9-40a7-b2a7-b3036347fafc	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=6fa2d194-8bb3-4b4d-82ea-b7601584bf73	0	2026-09-01 10:13:49.285705
461	34658c01-57c9-40a7-b2a7-b3036347fafc	status_validating	VALIDATING	Validation started	0	2026-09-01 10:13:49.321309
462	34658c01-57c9-40a7-b2a7-b3036347fafc	status_running	RUNNING	Execution started	0	2026-09-01 10:13:59.355012
463	34658c01-57c9-40a7-b2a7-b3036347fafc	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=4.31s; stdout=/usr/bin/curl\n; stderr=	0	2026-09-01 10:14:18.704331
464	34658c01-57c9-40a7-b2a7-b3036347fafc	verification_result	SUCCESS	Verification output: /usr/bin/curl\n	0	2026-09-01 10:14:18.716443
465	34658c01-57c9-40a7-b2a7-b3036347fafc	execution_time	SUCCESS	Execution took 4.34 seconds	0	2026-09-01 10:14:18.723366
466	34658c01-57c9-40a7-b2a7-b3036347fafc	status_verifying	VERIFYING	Verification started	0	2026-09-01 10:14:28.762275
467	34658c01-57c9-40a7-b2a7-b3036347fafc	status_success	SUCCESS	Execution completed successfully	0	2026-09-01 10:14:38.777475
468	34658c01-57c9-40a7-b2a7-b3036347fafc	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=6fa2d194-8bb3-4b4d-82ea-b7601584bf73	0	2026-09-01 10:14:38.790419
469	8b351617-3422-4c47-b096-507cf8c56931	job_received	SUCCESS	Job request accepted and stored	0	2026-09-01 10:19:50.00097
470	8b351617-3422-4c47-b096-507cf8c56931	job_auto_queued	SUCCESS	ServiceNow request auto-queued. celery_task_id=671a48b9-b937-46d9-9a4a-7be3170a632d	0	2026-09-01 10:19:50.051946
471	8b351617-3422-4c47-b096-507cf8c56931	celery_task_received	SUCCESS	Celery worker received task. celery_task_id=671a48b9-b937-46d9-9a4a-7be3170a632d	0	2026-09-01 10:19:50.059726
472	8b351617-3422-4c47-b096-507cf8c56931	status_validating	VALIDATING	Validation started	0	2026-09-01 10:19:50.067913
473	8b351617-3422-4c47-b096-507cf8c56931	status_running	RUNNING	Execution started	0	2026-09-01 10:20:00.080302
474	8b351617-3422-4c47-b096-507cf8c56931	execution_result	SUCCESS	transport=ssh; exit_code=0; duration=5.61s; stdout=/usr/bin/curl\n; stderr=	0	2026-09-01 10:20:20.69545
475	8b351617-3422-4c47-b096-507cf8c56931	verification_result	SUCCESS	Verification output: /usr/bin/curl\n	0	2026-09-01 10:20:20.702702
476	8b351617-3422-4c47-b096-507cf8c56931	execution_time	SUCCESS	Execution took 5.61 seconds	0	2026-09-01 10:20:20.710796
477	8b351617-3422-4c47-b096-507cf8c56931	status_verifying	VERIFYING	Verification started	0	2026-09-01 10:20:30.765475
478	8b351617-3422-4c47-b096-507cf8c56931	status_success	SUCCESS	Execution completed successfully	0	2026-09-01 10:20:40.801808
479	8b351617-3422-4c47-b096-507cf8c56931	celery_task_completed	SUCCESS	Celery task completed. celery_task_id=671a48b9-b937-46d9-9a4a-7be3170a632d	0	2026-09-01 10:20:40.81436
480	d7797519-07cc-4943-810d-f0928fd2d2f1	job_received	SUCCESS	Job request accepted and stored	0	2026-09-01 10:23:56.144711
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, ticket_id, module, status, target_host, os_type, software_name, software_version, requested_by, justification, trace_id, created_at, updated_at, retry_count, max_retries, timeout_seconds, last_error, execution_mode, scheduled_time, target_port, connection_method, request_source, request_reference, notes) FROM stdin;
24a08414-11d2-4a64-be59-550c557a0801	RITM900007	sw-install	PENDING	172.17.0.2	linux	vim	\N	\N	\N	beac12a0-cd6a-40b9-bd1e-5a695913910d	2026-07-23 09:17:45.031896	2026-07-23 09:17:45.031906	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
a2e7bcb4-8b83-4388-a79d-0ce7ddb6cff3	RITM9000206	sw-install	FAILED_FINAL	host.docker.internal	linux	curl	latest	aronbabu	Linux Test2 git install	25fc7489-71ae-46d7-bcd5-4be048f83730	2026-08-17 12:11:29.551869	2026-08-17 12:13:59.735276	3	3	300	E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)\nE: Unable to lock the administration directory (/var/lib/dpkg/), is another process using it?\n	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
7d1a4226-53ac-43f3-b969-953de4c2e648	RITM900007	sw-install	PENDING	172.17.0.2	linux	vim	\N	\N	\N	6e7301bf-2ad4-4ec6-afe3-6dbf5fdf9d68	2026-07-23 09:18:00.113666	2026-07-23 09:18:00.113669	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
db6bc06e-e9ab-4304-b2d3-abc0d453e75d	RITM9000201	sw-install	PENDING	127.0.0.2	linux	vim	\N	\N	\N	ffcd5ed6-8eaf-4e07-bfc4-44fe33725ced	2026-07-29 09:07:19.127038	2026-07-29 09:07:19.127042	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
324f6daf-d333-4280-9b99-fa7dee9ecaab	RITM900001	sw-install	SUCCESS	127.0.0.1	linux	curl	\N	\N	\N	ee976c07-e469-40d8-8afc-27a59bc93405	2026-06-21 14:47:20.228798	2026-06-21 14:48:18.10349	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
abd2db65-3e59-4cc2-a3ee-eb0e954c5a1c	RITM9000202	sw-install	PENDING	host.docker.internal	linux	vim	latest	aronbabu	Docker Linux SSH test through Redis Celery	ffa3cb08-36d1-4674-845c-f93b78c7f934	2026-07-29 09:23:42.823335	2026-07-29 09:23:42.823344	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
ba5dc69a-039f-472b-9bdb-2f88ca5e8992	RITM900002	sw-install	RUNNING	127.0.0.1	linux	curl	\N	\N	\N	c220b031-49a3-46f2-8e15-1cc351071623	2026-06-21 14:56:32.651328	2026-06-21 14:56:52.159548	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
dee5feb6-07f7-4174-8801-fa3258766e7f	RITM900006	sw-install	VERIFYING	127.0.0.1	windows	7zip	\N	\N	\N	dd466a54-f1ad-40d5-ae70-d8333c35ac69	2026-06-23 13:09:19.449972	2026-06-23 13:11:43.476243	3	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
019a244a-2739-467e-9eab-be388626928b	RITM900003	sw-install	FAILED	127.0.0.1	linux	vim	\N	\N	\N	6b417d67-eea9-421b-a877-0be060b50075	2026-06-23 11:04:14.808471	2026-06-23 11:04:50.736765	0	3	300	Software 'vim' not approved for os_type 'linux'	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
532a0309-43e7-43c4-b6b2-f7d3bdb6a466	RITM9000206	sw-install	RUNNING	host.docker.internal	linux	curl	latest	aronbabu	Docker Linux SSH test through Redis Celery	02b8af0a-24a8-440c-b89f-bee5204abeda	2026-07-29 13:27:07.65355	2026-07-29 13:27:29.859474	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
588390e1-a563-4568-9289-1bdecf3a4acf	RITM900003	sw-install	FAILED	127.0.0.1	linux	vim	\N	\N	\N	dffb9900-07a7-4412-980f-38eddbb81044	2026-06-23 11:09:07.035417	2026-06-23 11:09:38.479217	0	3	300	Software 'vim' not approved for os_type 'linux'	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
a258a959-57ac-4d52-b278-a81daae14be0	RITM9000205	sw-install	FAILED_FINAL	host.docker.internal	linux	vim	latest	aronbabu	Docker Linux SSH test through Redis Celery	d8cee654-93f2-4d94-ab07-f20633b001ca	2026-07-29 10:32:03.891135	2026-07-29 10:34:31.623349	3	3	300	E: Unable to locate package vim\n	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
46a51e5a-87d2-4a83-b24b-3f84162a8287	RITM900007	sw-install	FAILED_FINAL	127.0.0.1	windows	7zip	\N	\N	\N	cc2fe40b-2e7c-4538-89a8-d12bd1b80ce1	2026-06-23 13:48:41.676669	2026-06-23 13:50:59.965287	3	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
6c214ddf-d81c-443c-9cbd-08ddbf6e6dba	RITM900006	sw-install	VERIFYING	127.0.0.1	windows	7zip	\N	\N	\N	3b4b3abd-a41f-4ac0-a82e-8ee4de0146b1	2026-06-23 13:05:51.914589	2026-06-23 13:08:15.777626	3	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
ac518ad0-ac03-4f0a-946f-80c0977fccf0	RITM900003	sw-install	SUCCESS	127.0.0.1	linux	vim	\N	\N	\N	ee2046be-cecf-4acc-9c08-b65343293508	2026-06-23 11:10:38.364185	2026-06-23 11:11:34.175013	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
9f58c752-dfc6-4125-8602-3ab735a20612	RITM9000202	sw-install	PENDING	127.0.0.2	linux	curl	\N	\N	\N	ee48948e-00f8-4424-a226-703953bd9811	2026-07-29 13:26:45.998797	2026-07-29 13:26:45.998802	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
1850dc66-f0b3-42cc-aa32-5e4ad390a6db	RITM900004	sw-install	FAILED	127.0.0.1	windows	7zip	\N	\N	\N	c1a2da05-82ad-41c8-a7e1-f40f6ac5fcd8	2026-06-23 12:24:57.366053	2026-06-23 12:25:37.314105	0	3	300	'install'	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
3d345319-8690-49ab-89b7-2a01df5d2b8a	RITM9000203	sw-install	FAILED	host.docker.internal	linux	git	latest	aronbabu	Linux Test2 git install	c4889703-4f02-406a-b6c9-c2ba0a3110d2	2026-08-17 10:10:17.251945	2026-08-17 10:12:48.903596	0	3	300	Software 'git' not approved for os_type 'linux'	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
e811b047-ebf2-41e2-983c-80cacea461fd	RITM900007	sw-install	FAILED_FINAL	127.0.0.1	windows	7zip	\N	\N	\N	6203f760-5c6d-4bee-a4a9-40375a202350	2026-06-23 13:29:02.006316	2026-06-23 13:31:21.650561	3	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
ff7538ae-b1a3-414a-b1e3-2da2fdcf93a5	RITM900005	sw-install	VERIFYING	127.0.0.1	windows	7zip	\N	\N	\N	49340bb2-727d-4332-8306-21075f651bdc	2026-06-23 12:53:45.897094	2026-06-23 12:54:38.756574	1	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
6ee800e6-01bc-47ce-8da9-6c3d6f49538c	RITM900004	sw-install	SUCCESS	127.0.0.1	linux	vim	\N	\N	\N	a638157f-21cf-41d5-8d16-b8b695404e65	2026-06-24 12:37:35.969807	2026-06-24 12:38:31.951538	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
8fa0b3a8-97a0-4d69-8e15-11b180b1ebfd	RITM900007	sw-install	FAILED_FINAL	127.0.0.1	windows	7zip	\N	\N	\N	1b52b3bb-994e-4e22-9912-1d188243d554	2026-06-23 13:23:20.002859	2026-06-23 13:25:54.425222	3	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
01153b27-ce1f-4ecd-8ea2-065b9ed0e948	RITM9000202	sw-install	FAILED_FINAL	host.docker.internal	linux	vim	latest	aronbabu	Docker Linux SSH test through Redis Celery	e59171a2-7753-4fa0-b6b5-21cbc6e6267f	2026-07-29 10:05:40.146029	2026-07-29 10:08:28.532949	3	3	300	E: Unable to locate package vim\n	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
2f57de4d-c4b0-40aa-83a8-7a2fb85139c0	RITM900007	sw-install	FAILED_FINAL	127.0.0.1	windows	7zip	\N	\N	\N	6161e91a-83fb-4a88-b333-ee1aabe5e690	2026-06-24 12:46:18.9284	2026-06-24 12:48:41.414838	3	3	300	auth method ntlm requires a username	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
c223baea-2c06-4aa5-b6cb-34b916340854	RITM700001	sw-install	PENDING	server01.company.net	windows	7zip	24.09	\N	\N	aa16402f-065a-4b89-abf3-2b063733d4ae	2026-07-22 11:12:49.495423	2026-07-22 11:12:49.495427	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
6602d431-20fc-4ea4-b3a5-4f3c16dca762	RITM900006	sw-install	SUCCESS	127.0.0.5	linux	vim	\N	\N	\N	2be847a0-18ce-4e8f-b653-e1a63a5743d8	2026-06-24 12:44:53.49962	2026-06-24 12:45:46.985913	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
cfaa06a9-a385-45ef-a39b-e6155cb83144	RITM700002	sw-install	PENDING	ubuntu-test	linux	curl	latest	aronbabu	Linux package install test through Redis Celery	8cf88e96-11fe-4128-a04b-bcb62100c88e	2026-07-22 13:34:57.439408	2026-07-22 13:34:57.439414	0	3	300	\N	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
3afb4f29-cf95-4672-8e8c-2c2dcfa7c851	RITM9000204	sw-install	FAILED	host.docker.internal	linux	vim	latest	aronbabu	Linux Test2 git install	542ad886-9449-4a64-916f-13dff2952aeb	2026-08-17 10:22:00.5821	2026-08-17 10:22:29.397264	0	3	300	[Errno None] Unable to connect to port 22 on 192.168.65.254	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
23a51c79-0d59-4958-a46b-67e0b020123b	RITM9000204	sw-install	FAILED	host.docker.internal	linux	vim	latest	aronbabu	Linux Test2 git install	7f7b3731-aa93-4b80-aa62-adfa5ccd77d9	2026-08-17 10:20:51.758766	2026-08-17 10:21:24.194499	0	3	300	[Errno None] Unable to connect to port 22 on 192.168.65.254	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
b8f6e288-7ba4-450e-a733-1932a87bc23a	RITM9000205	sw-install	FAILED	host.docker.internal	linux	vim	latest	aronbabu	Linux Test2 git install	13e1bc4c-3182-4e1b-9220-b9d6165130ab	2026-08-17 11:13:48.01787	2026-08-17 11:14:22.123076	0	3	300	[Errno None] Unable to connect to port 22 on 192.168.65.254	immediate	\N	22	openssh	ADMIN_PORTAL	\N	\N
90a78291-d3d8-4697-ad5e-a5787b8bd9a5	RITM9000206	sw-install	RUNNING	host.docker.internal	linux	vim	latest	aronbabu	Linux Test2 git install	5c67c4ef-cb5b-4056-b77d-3a00bd73fc8c	2026-08-17 11:34:30.004578	2026-08-17 11:35:03.57516	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
3f1f87c3-501d-481d-9f2c-29675e4f3df8	RITM9000207	sw-install	SUCCESS	host.docker.internal	linux	curl	latest	aronbabu	Linux Test2 git install	435d075c-3516-4abb-8c91-f8d36aded598	2026-08-17 12:12:34.688002	2026-08-17 12:13:27.126594	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	\N	\N
13a6f3cd-3c72-4900-a649-d0764220c4f3	RITM9000208	sw-install	PENDING	host.docker.internal	linux	curl	\N	aron	Authorization validation	0b46f95e-9d68-4e28-a933-c757efe35ce6	2026-08-28 10:51:19.622116	2026-08-28 10:51:19.622121	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	PORTAL-001	\N
87f4521f-0784-4c34-940e-23393825358d	RITM9000209	sw-install	PENDING	host.docker.internal	linux	curl	\N	babu	Authorization validation	65ead785-4175-40d4-b0f5-805ec579d52a	2026-08-28 11:39:09.062195	2026-08-28 11:39:09.062204	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	PORTAL-002	\N
05f28223-5bf7-48ef-8345-93b8ad24214e	RITM9000210	sw-install	PENDING	host.docker.internal	linux	curl	\N	babu	Authorization validation	863f0724-45c9-41a6-a01c-c78c5b629495	2026-08-30 12:04:51.743696	2026-08-30 12:04:51.743702	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	PORTAL-002	\N
d1544238-c3c4-4ae9-a114-038e3aff67bc	RITM9999001	sw-install	FAILED	host.docker.internal	linux	git	latest	servicenow_svc	Test from ServiceNow	e0739097-7220-4f9f-8921-226b19de9f68	2026-08-30 13:53:31.745743	2026-08-30 13:53:57.012061	0	3	300	Software 'git' not approved for os_type 'linux'	immediate	\N	2221	openssh	SERVICENOW	RITM9999001	\N
ccb52173-d97b-4ea0-b45a-d72629a403e4	RITM9000208	sw-install	SUCCESS	host.docker.internal	linux	curl	\N	aron	Authorization validation	ffec8414-9512-4a17-859c-023da7b4ed44	2026-08-28 11:24:16.104071	2026-08-28 11:25:11.11159	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	PORTAL-001	\N
2c134a82-9ea2-483e-9c8c-790506c677ad	PORTAL-001	sw-install	PENDING	host.docker.internal	linux	vim	latest	aron	Portal test	24b4a783-8de1-43c5-8094-ddf6ab072bcb	2026-08-30 13:57:55.124501	2026-08-30 13:57:55.124509	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
d09eaf89-52e6-4df0-a0b8-6f44ea996de9	RITM9999002	sw-install	SUCCESS	host.docker.internal	linux	vim	latest	servicenow_svc	Test from ServiceNow	812426d0-260e-48a5-b678-13e0067deb40	2026-08-30 14:08:47.358569	2026-08-30 14:09:39.337798	0	3	300	\N	immediate	\N	2221	openssh	SERVICENOW	RITM9999001	\N
a7de03cb-9545-453c-9ef6-36a861ddd509	PORTAL-001	sw-install	PENDING	host.docker.internal	linux	vim	latest	aron	Portal test	6f8aaea7-d46b-42e6-8072-c80c1a1308ab	2026-08-30 14:36:32.382887	2026-08-30 14:36:32.382897	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
0b742fe1-4149-45e6-8dc3-b4b342e433db	PORTAL-021	sw-install	FAILED_FINAL	host.docker.internal	linux	vim	latest	aron	Test from portal	3217edfd-eb37-4bc7-b3ae-51b3d3c12a29	2026-09-01 07:21:00.964895	2026-09-01 07:25:56.422414	3	3	300	[Errno None] Unable to connect to port 2221 on 192.168.65.254	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
d7797519-07cc-4943-810d-f0928fd2d2f1	RITM9919004	sw-install	PENDING	host.docker.internal	linux	curl	\N	aron	test from admin portal by aron	71b0f655-42b6-4aa5-8bc2-d551374a356b	2026-09-01 10:23:56.125065	2026-09-01 10:23:56.125069	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	RITM9919004	test from admin portal by aron
f2e52d0d-9755-4a6a-b949-db8a7fa6bded	PORTAL-ARON-001	sw-install	SUCCESS	host.docker.internal	linux	curl	latest	aron	Test with aron user	aa8ca350-50dd-495b-8da7-292f1531fbb9	2026-08-30 14:17:59.056077	2026-08-30 14:21:04.579937	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
fabcf2a8-1b80-4dc3-a53e-33339cd66c18	PORTAL-001	sw-install	PENDING	host.docker.internal	linux	vim	latest	aron	Portal test	fa8f72cf-55c4-407a-a28c-e82cd492d34c	2026-08-30 14:39:38.148179	2026-08-30 14:39:38.148182	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
2123c253-287d-4fdd-bf72-f48871682f3f	PORTAL-001	sw-install	PENDING	host.docker.internal	linux	git	latest	aron	Portal test	a1c2fc58-b91f-4df3-acd7-9989b3898314	2026-08-30 14:40:08.301386	2026-08-30 14:40:08.301389	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
6fc1dff3-5f11-42a1-b308-a0343702a9ee	PORTAL-022	sw-install	SUCCESS	host.docker.internal	linux	vim	latest	aron	Test from portal	90e2e675-2b38-4006-adb2-6626c48b76c6	2026-09-01 07:25:34.197961	2026-09-01 07:26:30.252079	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	\N	\N
5ca70672-caac-4008-be0f-ebec84e9072f	RITM9999002	sw-install	SUCCESS	host.docker.internal	linux	git	latest	servicenow_svc	Test from ServiceNow	9af9f495-776c-472e-b419-6cf37d1dfb85	2026-08-30 14:42:43.474794	2026-08-30 14:43:48.972091	0	3	300	\N	immediate	\N	2221	openssh	SERVICENOW	RITM9999001	\N
34658c01-57c9-40a7-b2a7-b3036347fafc	RITM9999005	sw-install	SUCCESS	host.docker.internal	linux	curl	\N	servicenow_svc	testing	c3bb58ff-30bc-43e0-a44f-de5c6f8f67fe	2026-09-01 10:13:48.384617	2026-09-01 10:14:38.775181	0	3	300	\N	immediate	\N	2222	openssh	SERVICENOW	RITM9999005	testing
7bd02baf-ce5a-4826-92a6-dbe24419c271	PORTAL-005	sw-install	SUCCESS	host.docker.internal	linux	vim	latest	aron	Portal test	870663c7-eb1c-476f-9aa9-9703a22c3979	2026-08-30 14:44:25.738377	2026-08-30 14:46:55.971614	0	3	300	\N	immediate	\N	2221	openssh	ADMIN_PORTAL	\N	\N
7e5d8179-9920-4b00-a382-06aa0964a61b	RITM9000207	sw-install	PENDING	host.docker.internal	linux	curl1	latest	aron	Docker Linux SSH test through Redis Celery	758e577f-63cb-4e24-8b86-b3e91fcf157d	2026-08-31 09:15:49.815986	2026-08-31 09:15:49.815997	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	\N	\N
6234cd22-e8c9-4603-8643-5e97b3476d78	RITM9000301	sw-install	PENDING	host.docker.internal	linux	curl	latest	aron	Docker Linux SSH test through Redis Celery	3e743fa0-8be1-420d-9112-8555785053a3	2026-08-31 09:19:56.188928	2026-08-31 09:19:56.188932	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	\N	\N
265be063-69d5-4a0c-a2ea-4e43d876e80d	RITM9000301	sw-install	SUCCESS	host.docker.internal	linux	curl	latest	aron	Docker Linux SSH test through Redis Celery	a2aebd5c-ce44-4999-a07a-9d8663901418	2026-08-31 09:23:32.730441	2026-08-31 09:25:23.129678	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	\N	\N
8b351617-3422-4c47-b096-507cf8c56931	RITM9991003	sw-install	SUCCESS	host.docker.internal	linux	curl	\N	servicenow_svc	test aronbabu	d0345d11-495a-4d3b-a1a6-923a75a6005f	2026-09-01 10:19:49.959186	2026-09-01 10:20:40.799017	0	3	300	\N	immediate	\N	2221	openssh	SERVICENOW	RITM9991003	test aronbabu
532a7329-068f-43e4-ad84-aa2f2e1c5277	RITM9919004	sw-install	PENDING	host.docker.internal	linux	curl	\N	babu	test from admin portal by babu	2a5687ca-4b97-4a1f-af98-971ccafd3f00	2026-09-01 10:22:08.021133	2026-09-01 10:22:08.021137	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	RITM9919004	test from admin portal by babu
3158e3bf-16c8-4707-bb06-27c1983ca81f	RITM9919004	sw-install	PENDING	host.docker.internal	linux	curl	\N	aronbabu	test from admin portal by babu	2fdc38f2-5a99-402a-9da3-a5427744b2c5	2026-09-01 10:22:17.200162	2026-09-01 10:22:17.200166	0	3	300	\N	immediate	\N	2222	openssh	ADMIN_PORTAL	RITM9919004	test from admin portal by babu
\.


--
-- Data for Name: service_account_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_account_credentials (id, user_id, service_name, api_key, active, description, created_at, updated_at) FROM stdin;
8de70554-d445-46c5-aabb-b56ec44a23c3	7edd6e16-beb0-4ce6-9339-465b24266c29	SERVICENOW	svc_8foW4E6x9wG0lO6lqBwEAOWUpFc5Ije0FJHY-FCSgyU	t	ServiceNow integration API key for auto-queueing requests	2026-08-30 13:49:47.738575	2026-08-30 13:49:47.738578
\.


--
-- Data for Name: software_catalogue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.software_catalogue (id, name, version, os_type, request_source, execution_mode, target_port, connection_method, status, notes, created_at, updated_at) FROM stdin;
b4630af7-73c8-448c-87a5-868a1196f7fe	curl	latest	linux	BOTH	immediate	2222	openssh	ACTIVE	Used for Linux install validation/testing.	2026-08-31 13:55:29.739058+00	2026-08-31 13:55:29.739058+00
74d41468-eb51-45b1-abd8-ad8611fc4b1f	Git	2.45	linux	ADMIN_PORTAL	immediate	2221	openssh	ACTIVE	Portal testing and developer utility.	2026-08-31 13:55:29.739058+00	2026-08-31 13:55:29.739058+00
66fb158b-0bce-4a21-9d27-ed95971c20df	7-Zip	23.01	windows	SERVICENOW	immediate	22	openssh	ACTIVE	Windows package install request item.	2026-08-31 13:55:29.739058+00	2026-08-31 13:55:29.739058+00
f7e74def-2a24-469f-bd94-fa44d0ad7d9f	Visual Studio Code	1.92	windows	BOTH	immediate	22	openssh	ACTIVE	Common editor package for portal and ServiceNow requests.	2026-08-31 13:55:29.739058+00	2026-08-31 13:55:29.739058+00
a31a6d83-0c4a-443d-a2ec-2edd95ba25aa	Notepad++	8.6	windows	ADMIN_PORTAL	immediate	22	openssh	ACTIVE	Useful for internal portal-driven testing.	2026-08-31 13:55:29.739058+00	2026-08-31 13:55:29.739058+00
\.


--
-- Name: job_steps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_steps_id_seq', 480, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: app_roles app_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_roles
    ADD CONSTRAINT app_roles_pkey PRIMARY KEY (id);


--
-- Name: app_roles app_roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_roles
    ADD CONSTRAINT app_roles_role_name_key UNIQUE (role_name);


--
-- Name: app_user_roles app_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user_roles
    ADD CONSTRAINT app_user_roles_pkey PRIMARY KEY (id);


--
-- Name: app_users app_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_email_key UNIQUE (email);


--
-- Name: app_users app_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_pkey PRIMARY KEY (id);


--
-- Name: app_users app_users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_users
    ADD CONSTRAINT app_users_username_key UNIQUE (username);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- Name: authorization_decisions authorization_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authorization_decisions
    ADD CONSTRAINT authorization_decisions_pkey PRIMARY KEY (id);


--
-- Name: decision_ledger decision_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.decision_ledger
    ADD CONSTRAINT decision_ledger_pkey PRIMARY KEY (id);


--
-- Name: job_steps job_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_steps
    ADD CONSTRAINT job_steps_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: service_account_credentials service_account_credentials_api_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_account_credentials
    ADD CONSTRAINT service_account_credentials_api_key_key UNIQUE (api_key);


--
-- Name: service_account_credentials service_account_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_account_credentials
    ADD CONSTRAINT service_account_credentials_pkey PRIMARY KEY (id);


--
-- Name: software_catalogue software_catalogue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.software_catalogue
    ADD CONSTRAINT software_catalogue_pkey PRIMARY KEY (id);


--
-- Name: ix_audit_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_events_created_at ON public.audit_events USING btree (created_at);


--
-- Name: ix_audit_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_events_event_type ON public.audit_events USING btree (event_type);


--
-- Name: ix_audit_events_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_events_job_id ON public.audit_events USING btree (job_id);


--
-- Name: ix_audit_events_request_reference; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_events_request_reference ON public.audit_events USING btree (request_reference);


--
-- Name: ix_audit_events_request_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_events_request_source ON public.audit_events USING btree (request_source);


--
-- Name: ix_decision_ledger_final_outcome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_decision_ledger_final_outcome ON public.decision_ledger USING btree (final_outcome);


--
-- Name: ix_decision_ledger_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_decision_ledger_job_id ON public.decision_ledger USING btree (job_id);


--
-- Name: ix_decision_ledger_request_reference; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_decision_ledger_request_reference ON public.decision_ledger USING btree (request_reference);


--
-- Name: ix_decision_ledger_request_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_decision_ledger_request_source ON public.decision_ledger USING btree (request_source);


--
-- Name: ix_job_steps_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_job_steps_job_id ON public.job_steps USING btree (job_id);


--
-- Name: ix_jobs_ticket_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_jobs_ticket_id ON public.jobs USING btree (ticket_id);


--
-- Name: ix_software_catalogue_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_software_catalogue_name ON public.software_catalogue USING btree (name);


--
-- Name: ix_software_catalogue_os_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_software_catalogue_os_type ON public.software_catalogue USING btree (os_type);


--
-- Name: ix_software_catalogue_request_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_software_catalogue_request_source ON public.software_catalogue USING btree (request_source);


--
-- Name: ix_software_catalogue_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_software_catalogue_status ON public.software_catalogue USING btree (status);


--
-- Name: app_user_roles app_user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user_roles
    ADD CONSTRAINT app_user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.app_roles(id);


--
-- Name: app_user_roles app_user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_user_roles
    ADD CONSTRAINT app_user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_users(id);


--
-- Name: authorization_decisions authorization_decisions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authorization_decisions
    ADD CONSTRAINT authorization_decisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_users(id);


--
-- Name: decision_ledger decision_ledger_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.decision_ledger
    ADD CONSTRAINT decision_ledger_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: job_steps job_steps_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_steps
    ADD CONSTRAINT job_steps_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE CASCADE;


--
-- Name: service_account_credentials service_account_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_account_credentials
    ADD CONSTRAINT service_account_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict OrOOInSTngDgiuej4MOjpsaEGaaG93Yck8o0VdwULF3Z2pFesxchrd24ueOEPfn

