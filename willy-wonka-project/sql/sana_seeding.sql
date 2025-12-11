USE db_willy_wonka;

INSERT INTO db_willy_wonka.factories (factory, latitude, longitude)
SELECT DISTINCT
    `Factory`      AS factory,
    `Latitude`,
    `Longitude`
FROM Willy_Wonka.wonka_choc_factory;

SELECT * FROM factories;