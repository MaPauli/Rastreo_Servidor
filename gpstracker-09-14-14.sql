-- phpMyAdmin SQL Dump
-- version 4.8.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 20-07-2018 a las 16:31:45
-- Versión del servidor: 10.1.31-MariaDB
-- Versión de PHP: 7.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gpstracker-09-14-14`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `prcDeleteRoute` (`_sessionID` VARCHAR(50))  BEGIN
  DELETE FROM gpslocations
  WHERE sessionID = _sessionID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prcGetAllRoutesForMap` ()  BEGIN
SELECT sessionId, gpsTime, CONCAT('{ "latitude":"', CAST(latitude AS CHAR),'", "longitude":"', CAST(longitude AS CHAR), '", "speed":"', CAST(speed AS CHAR), '", "direction":"', CAST(direction AS CHAR), '", "distance":"', CAST(distance AS CHAR), '", "locationMethod":"', locationMethod, '", "gpsTime":"', DATE_FORMAT(gpsTime, '%b %e %Y %h:%i%p'), '", "userName":"', userName, '", "phoneNumber":"', phoneNumber, '", "sessionID":"', CAST(sessionID AS CHAR), '", "accuracy":"', CAST(accuracy AS CHAR), '", "extraInfo":"', extraInfo, '" }') json
FROM (SELECT MAX(GPSLocationID) ID
      FROM gpslocations
      WHERE sessionID != '0' && CHAR_LENGTH(sessionID) != 0 && gpstime != '0000-00-00 00:00:00'
      GROUP BY sessionID) AS MaxID
JOIN gpslocations ON gpslocations.GPSLocationID = MaxID.ID
ORDER BY gpsTime;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prcGetRouteForMap` (`_sessionID` VARCHAR(50))  BEGIN
  SELECT CONCAT('{ "latitude":"', CAST(latitude AS CHAR),'", "longitude":"', CAST(longitude AS CHAR), '", "speed":"', CAST(speed AS CHAR), '", "direction":"', CAST(direction AS CHAR), '", "distance":"', CAST(distance AS CHAR), '", "locationMethod":"', locationMethod, '", "gpsTime":"', DATE_FORMAT(gpsTime, '%b %e %Y %h:%i%p'), '", "userName":"', userName, '", "phoneNumber":"', phoneNumber, '", "sessionID":"', CAST(sessionID AS CHAR), '", "accuracy":"', CAST(accuracy AS CHAR), '", "extraInfo":"', extraInfo, '" }') json
  FROM gpslocations
  WHERE sessionID = _sessionID
  ORDER BY lastupdate;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prcGetRoutes` ()  BEGIN
  CREATE TEMPORARY TABLE tempRoutes (
    sessionID VARCHAR(50),
    userName VARCHAR(50),
    startTime DATETIME,
    endTime DATETIME)
  ENGINE = MEMORY;

  INSERT INTO tempRoutes (sessionID, userName)
  SELECT DISTINCT sessionID, userName
  FROM gpslocations;

  UPDATE tempRoutes tr
  SET startTime = (SELECT MIN(gpsTime) FROM gpslocations gl
  WHERE gl.sessionID = tr.sessionID
  AND gl.userName = tr.userName);

  UPDATE tempRoutes tr
  SET endTime = (SELECT MAX(gpsTime) FROM gpslocations gl
  WHERE gl.sessionID = tr.sessionID
  AND gl.userName = tr.userName);

  SELECT

  CONCAT('{ "sessionID": "', CAST(sessionID AS CHAR),  '", "userName": "', userName, '", "times": "(', DATE_FORMAT(startTime, '%b %e %Y %h:%i%p'), ' - ', DATE_FORMAT(endTime, '%b %e %Y %h:%i%p'), ')" }') json
  FROM tempRoutes
  ORDER BY startTime DESC;

  DROP TABLE tempRoutes;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prcSaveGPSLocation` (`_latitude` DECIMAL(10,7), `_longitude` DECIMAL(10,7), `_speed` INT(10), `_direction` INT(10), `_distance` DECIMAL(10,1), `_date` TIMESTAMP, `_locationMethod` VARCHAR(50), `_userName` VARCHAR(50), `_phoneNumber` VARCHAR(50), `_sessionID` VARCHAR(50), `_accuracy` INT(10), `_extraInfo` VARCHAR(255), `_eventType` VARCHAR(50))  BEGIN
   INSERT INTO gpslocations (latitude, longitude, speed, direction, distance, gpsTime, locationMethod, userName, phoneNumber,  sessionID, accuracy, extraInfo, eventType)
   VALUES (_latitude, _longitude, _speed, _direction, _distance, _date, _locationMethod, _userName, _phoneNumber, _sessionID, _accuracy, _extraInfo, _eventType);
   SELECT NOW();
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gpslocations`
--

CREATE TABLE `gpslocations` (
  `GPSLocationID` int(10) UNSIGNED NOT NULL,
  `lastUpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `latitude` decimal(10,7) NOT NULL DEFAULT '0.0000000',
  `longitude` decimal(10,7) NOT NULL DEFAULT '0.0000000',
  `phoneNumber` varchar(50) NOT NULL DEFAULT '',
  `userName` varchar(50) NOT NULL DEFAULT '',
  `sessionID` varchar(50) NOT NULL DEFAULT '',
  `speed` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `direction` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `distance` decimal(10,1) NOT NULL DEFAULT '0.0',
  `gpsTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `locationMethod` varchar(50) NOT NULL DEFAULT '',
  `accuracy` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `extraInfo` varchar(255) NOT NULL DEFAULT '',
  `eventType` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `gpslocations`
--

INSERT INTO `gpslocations` (`GPSLocationID`, `lastUpdate`, `latitude`, `longitude`, `phoneNumber`, `userName`, `sessionID`, `speed`, `direction`, `distance`, `gpsTime`, `locationMethod`, `accuracy`, `extraInfo`, `eventType`) VALUES
(21, '2018-07-16 22:10:39', '0.9733940', '-79.6570870', '5d138a16-4e6e-46fb-bdfb-ae6d1e4266ad', 'veronica', 'bc022c12-f4fb-47fb-9b15-ae44f25b2bed', 24, 57, '0.0', '2018-07-16 22:12:15', 'fused', 1312, '-359', 'android'),
(22, '2018-07-16 22:01:09', '0.9710700', '-79.6564000', '5d138a16-4e6e-46fb-bdfb-ae6d1e4266ad', 'veronica', 'bc022c12-f4fb-47fb-9b15-ae44f25b2bed', 24, 57, '0.0', '2018-07-16 22:03:15', 'fused', 1312, '-359', 'android');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `gpslocations`
--
ALTER TABLE `gpslocations`
  ADD PRIMARY KEY (`GPSLocationID`),
  ADD KEY `sessionIDIndex` (`sessionID`),
  ADD KEY `phoneNumberIndex` (`phoneNumber`),
  ADD KEY `userNameIndex` (`userName`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `gpslocations`
--
ALTER TABLE `gpslocations`
  MODIFY `GPSLocationID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
