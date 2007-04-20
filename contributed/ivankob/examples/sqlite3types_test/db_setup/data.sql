begin;

create table datatypes_test (
    integerf1		integer,
    largeintf1		largeint,
    wordf1		word,
    smallintf1		smallint,
    booleanf1		boolean,
    realfloatdoublef1	float,
    datetimef1		datetime,
    datef1		date,
    timef1		time,
    numericf1		numeric,
    currencyf1		currency,
    vcharf1		varchar,
    textf1		text,
    blobf1		blob
);

insert into datatypes_test (
    integerf1,
    largeintf1,
    wordf1,
    smallintf1,
    booleanf1,
    realfloatdoublef1,
    datetimef1,
    datef1,
    timef1,
    numericf1,
    currencyf1,
    vcharf1,
    textf1
) values (
    2147483641,
    9223372036854775805,
    65501,
    -32700,    
    1 = 1,
    1.7e+37,
    '2007-04-01 01:59:30',
    '2007-04-01',
    '01:59:30',
    1234567890.0987654321,
    9876543210.0123456789,
    'vchar_qwerty',
    'text_qwerty'
);

commit;
