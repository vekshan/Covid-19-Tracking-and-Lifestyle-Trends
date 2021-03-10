-- Create all dimension tables except Fact table:

create table weather_dimension(
weather_surrogate_key int,
station_name varchar,
daily_high_temperature float,
daily_low_temperature float,
precipitation float,
primary key (weather_surrogate_key)
);

create table mobility_dimension(
mobility_surrogate_key int,
metro_area varchar,
province varchar,
subregion varchar,
retail_and_recreation int,
grocery_and_pharmacy int,
parks int,
transit_stations int,
workplaces int,
residential int,
primary key (mobility_surrogate_key)
);

create table date_dimension(
date_surrogate_key int,
full_date date,
day int,
month int,
year int,
day_of_year int,
day_of_week int,
week_in_year int,
quarter int,
is_weekend bool, 
is_week_day bool, 
is_holiday bool, 
holiday_name varchar,
season varchar,
primary key (date_surrogate_key)
);

create table patient_dimension(
patient_surrogate_key int,
gender varchar,
age_group varchar,
acquisition_group varchar,
outbreak_related bool, 
primary key (patient_surrogate_key)
);

create table phu_location_dimension(
phu_location_surrogate_key int,
phu_location_id int,
phu_name varchar,
address varchar,
city varchar,
postal_code varchar,
province varchar,
url varchar,
latitude float,
longitude float,
primary key (phu_location_surrogate_key)
);

create table special_measures_dimension(
special_measures_surrogate_key int,
title varchar,
description varchar,
tag_1 varchar,
tag_2 varchar,
start_date date,
end_date date,
primary key(special_measures_surrogate_key)
);

-- Create Views based on date_dimension table:

create view onset_date_dimension as
select *
from date_dimension;

create view reported_date_dimension as
select *
from date_dimension

create view test_date_dimension as
select *
from date_dimension

create view specimen_date_dimension as
select *
from date_dimension

-- Create Fact table:

create table covid19_tracking_fact_table(
onset_date_surrogate_key int,
reported_date_surrogate_key int,
test_date_surrogate_key int,
specimen_date_surrogate_key int,
patient_surrogate_key int,
phu_location_surrogate_key int,
mobility_surrogate_key int,
special_measures_surrogate_key int,
weather_surrogate_key int,
resolved bool,
unresolved bool,
fatal bool,
foreign key  (onset_date_surrogate_key) references date_dimension(date_surrogate_key),
foreign key  (reported_date_surrogate_key) references date_dimension(date_surrogate_key),
foreign key  (test_date_surrogate_key) references date_dimension(date_surrogate_key),
foreign key  (specimen_date_surrogate_key) references date_dimension(date_surrogate_key),
foreign key  (patient_surrogate_key) references patient_dimension(patient_surrogate_key),
foreign key  (phu_location_surrogate_key) references phu_location_dimension(phu_location_surrogate_key),
foreign key  (mobility_surrogate_key) references mobility_dimension(mobility_Surrogate_Key),
foreign key  (special_measures_surrogate_key) references special_measures_dimension(special_measures_surrogate_key),
foreign key  (weather_surrogate_key) references weather_dimension(weather_surrogate_key)
);