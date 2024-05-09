drop table ride_data_points, rides;

create table rides(
    id serial primary key,
    title varchar(255),
    finished_at timestamp,
    duration integer not null
);

create table ride_data_points (
    id serial primary key,
    ride_id integer not null,
    elapsed_msec integer not null,
    gps_latitude real,
    gps_longitude real,
    water_temperature real,
    engine_rpm integer,
    wheel_speed real,
    gear_position varchar(1),
    constraint fk_ride foreign key(ride_id) references rides(id)
);
