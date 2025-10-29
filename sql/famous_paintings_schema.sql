drop table if exists artist;
create table artist (
artist_id bigint generated always as identity primary key,
full_name text,
first_name text,
middle_names text,
last_name text,
nationality text,
style text,
birth int,
death int
);
copy artist(artist_id, full_name, first_name, middle_names, last_name, nationality, style, birth, death)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/artist.csv'
delimiter ','
csv header;


drop table if exists museum;
create table museum (
museum_id bigint generated always as identity primary key,
name text,
address text,
city text,
state text,
postal text,
country text,
phone text,
url text
);
copy museum(museum_id, name, address, city, state, postal, country, phone, url)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/museum.csv'
delimiter ','
csv header;


drop table if exists canvas_size;
create table canvas_size (
size_id bigint generated always as identity primary key,
width int,
height int,
label text
);
copy canvas_size(size_id, width, height, label)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/canvas_size.csv'
delimiter ','
csv header;


drop table if exists work;
create table temp_table (
work_id bigint,
name text,
artist_id bigint references artist(artist_id) on delete cascade,
style text,
museum_id bigint references museum(museum_id) on delete cascade
);
copy temp_table(work_id, name, artist_id, style, museum_id)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/work.csv'
delimiter ','
csv header;
create table work (
work_id bigint primary key,
name text,
artist_id bigint references artist(artist_id) on delete cascade,
style text,
museum_id bigint references museum(museum_id) on delete cascade
);
insert into work(work_id, name, artist_id, style, museum_id)
select distinct * --remove duplicates in the source table
from temp_table;
drop table if exists temp_table;



drop table if exists product_size;
create table temp_table ( 
work_id bigint,
size_id text,
sale_price int,
regular_price int
);
copy temp_table(work_id, size_id, sale_price, regular_price)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/product_size.csv'
delimiter ','
csv header;
create table product_size (
id bigint generated always as identity primary key, 
work_id bigint references work(work_id) on delete cascade,
size_id bigint references canvas_size(size_id) on delete cascade,
invalid_size_id text, --create a new column to store invalid size_id
sale_price int,
regular_price int
);

INSERT INTO product_size(work_id, size_id, invalid_size_id, sale_price, regular_price)
SELECT work_id, 
	   case
	   	when size_id ~ '^[0-9]+$'
	   		 and size_id in (select size_id from temp_table)
	   	then size_id::bigint
	   	else null
	   end as size_id,
	   case 
	   	when size_id ~ '^[0-9]+$'
	   		 and size_id in (select size_id from temp_table)
	   	then null 
	   	else size_id
	   end as invalid_size_id,
	   sale_price, regular_price
FROM temp_table;
drop table if exists temp_table;



drop table if exists image_link;
create table image_link (
id bigint generated always as identity primary key, --there is no suitable primary key in the table; create a surrogate pk
work_id bigint references work(work_id) on delete cascade,
url text,
thumbnail_small_url text,
thumbnail_large_url text
);
copy image_link(work_id, url, thumbnail_small_url, thumbnail_large_url)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/image_link.csv'
delimiter ','
csv header;



drop table if exists museum_hours;
create table museum_hours (
id bigint generated always as identity primary key,
museum_id bigint references museum(museum_id) on delete cascade,
day text,
open time,
close time
);
copy museum_hours(museum_id, day, open, close)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/museum_hours.csv'
delimiter ','
csv header;



drop table if exists subject;
create table subject (
id bigint generated always as identity primary key,
work_id bigint,
foreign key (work_id) references work(work_id) on delete cascade,
subject text
);
copy subject(work_id, subject)
from '/Users/Documents/GitHub/Famous_Paintings_Postgresql/data/subject.csv'
delimiter ','
csv header;






