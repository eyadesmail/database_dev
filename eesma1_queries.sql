/*
%Eyad Esmail%
%eesma1@unh.newhaven.edu%
Course Project
CSCI 6622, Spring 2019
Section %1 
Instructor: Sheehan
*/


USE eesma1_project;

# 1: List all services offered by the company, sorted alphabetically by category and then alphabetically by the service name.

SELECT	 Service_Category, Service_Name
FROM	 services
ORDER BY service_category, service_name ASC;
#-----------------------------------------------------------------------------------------------------------------------------

#2: List the names of all customers who had hard drives replaced in the last 30 days.
SELECT 	Business_name
FROM 	customers
WHERE 	customer_ID IN (
						SELECT 	custid
						FROM	appointments
						WHERE date BETWEEN DATE_SUB(NOW(), INTERVAL 30 DAY) AND NOW()
						AND appointment_id IN (
												SELECT	appointmentid
												FROM	appointment_srvs
												WHERE servicename = 'hard-drive-replacement'));
#----------------------------------------------------------------------------------------------------------------------------

#3:List the names of all customers who bought both hardware and software services (either in the same appointment or separate appointments).
									
SELECT	DISTINCT Business_Name 
From	customers  C
JOIN	appointments app on custid = customer_id
JOIN	appointment_srvs apsrvs on appointmentID = Appointment_ID
JOIN	services srvs on service_name=serviceName
WHERE	service_category = 'hardware' 
AND 	BUSINESS_NAME IN (
							SELECT	Business_Name 
							From	customers  C
							JOIN	appointments app on custid = customer_id
							JOIN	appointment_srvs apsrvs on appointmentID = Appointment_ID
							JOIN	services srvs on service_name=serviceName
							WHERE	service_category = 'SOFTWARE');
                            
#-----------------------------------------------------------------------------------------------------------------------------------

#4: List all technicians who have performed operating system upgrades and the total number of hours each technician spent on those upgrades.
                            

SELECT		tech_id, First_name, last_name, sum(duration) AS total_duration
FROM		technician
JOIN 		appointments ap ON techid = tech_id 
JOIN 		appointment_srvs aps ON appointment_id = appointmentid
WHERE 		ServiceName = 'operating-system-upgrade'
GROUP BY 	tech_id;

#----------------------------------------------------------------------------------------------------------------------------

#5: List all customers who bought data recovery services but did not buy any other item.


SELECT		BUSINESS_NAME
FROM		CUSTOMERS
JOIN		appointments app on custid = customer_id
JOIN		appointment_srvs apsrvs on appointmentID = Appointment_ID
JOIN		services srvs on service_name=serviceName
WHERE		service_name = 'DATA-RECOVERY'
AND			BUSINESS_NAME  	IN		(
										SELECT		BUSINESS_NAME
										FROM		CUSTOMERS
										WHERE		BUSINESS_NAME NOT IN (
																			SELECT	Business_Name 
																			From	customers  C
																			JOIN	appointments app on custid = customer_id
																			JOIN	appointment_srvs apsrvs on appointmentID = Appointment_ID
																			JOIN	services srvs on service_name=serviceName
																			WHERE	service_category = 'SOFTWARE' OR service_category = 'HARDWARE'));

#-----------------------------------------------------------------------------------------------------------------------------------------------------------


#6: List the names of the customer (or customers) who spent the greatest dollar amount in a single appointment.									

SELECT	temp.business_name 
FROM  	( 
			SELECT APPOINTMENTID,business_name ,SUM(PRICE) AS TP
			FROM	appointment_srvs
			JOIN	appointments on appointmentid = appointment_id
			join	customers on custid = customer_id
			GROUP BY APPOINTMENTID) as temp
WHERE	 	temp.tp = (
					   SELECT	max(temp.tp)
					   FROM (
							SELECT APPOINTMENTID,business_name ,SUM(PRICE) AS TP
							FROM	appointment_srvs
							JOIN	appointments on appointmentid = appointment_id
							join	customers on custid = customer_id
							GROUP BY APPOINTMENTID) as temp);
                            
         
#------------------------------------------------------------------------------------------------------------------------

#7: List each category, the name of the customer who has spent the most on services in that category, and the total amount of money that customer spent in that category.

SELECT	 temp.service_category , temp.business_name, total_price
FROM	(
		SELECT	 service_category , business_name,  sum(price) AS total_price
		FROM	 services
		JOIN	 appointment_srvs ON servicename = service_name 
		JOIN 	 appointments ON appointmentid = appointment_id
		JOIN 	 customers ON custid = customer_id
		WHERE	 service_category = 'hardware'
		GROUP BY business_name ) AS temp 
WHERE 	total_price = ( 
						SELECT 		max( total_price)
						FROM 	   (
									SELECT	 service_category , business_name,  sum(price) AS total_price
									FROM 	 services
									JOIN	 appointment_srvs on servicename = service_name 
									JOIN	 appointments on appointmentid = appointment_id
									JOIN 	 customers on custid = customer_id
									WHERE 	 service_category = 'hardware'
									GROUP BY business_name )as temp)

UNION 

SELECT	 temp.service_category , temp.business_name, total_price
FROM	(
		SELECT	 service_category , business_name,  sum(price) AS total_price
		FROM	 services
		JOIN	 appointment_srvs ON servicename = service_name 
		JOIN 	 appointments ON appointmentid = appointment_id
		JOIN 	 customers ON custid = customer_id
		WHERE	 service_category = 'software'
		GROUP BY business_name ) AS temp 
WHERE 	total_price = ( 
						SELECT 		max( total_price)
						FROM 	   (
									SELECT	 service_category , business_name,  sum(price) AS total_price
									FROM 	 services
									JOIN	 appointment_srvs on servicename = service_name 
									JOIN	 appointments on appointmentid = appointment_id
									JOIN 	 customers on custid = customer_id
									WHERE 	 service_category = 'software'
									GROUP BY business_name )as temp)
UNION 

SELECT	 temp.service_category , temp.business_name, total_price
FROM	(
		SELECT	 service_category , business_name,  sum(price) AS total_price
		FROM	 services
		JOIN	 appointment_srvs ON servicename = service_name 
		JOIN 	 appointments ON appointmentid = appointment_id
		JOIN 	 customers ON custid = customer_id
		WHERE	 service_category = 'recovery'
		GROUP BY business_name ) AS temp 
WHERE 	total_price = ( 
						SELECT 		max( total_price)
						FROM 	   (
									SELECT	 service_category , business_name,  sum(price) AS total_price
									FROM 	 services
									JOIN	 appointment_srvs on servicename = service_name 
									JOIN	 appointments on appointmentid = appointment_id
									JOIN 	 customers on custid = customer_id
									WHERE 	 service_category = 'recovery'
									GROUP BY business_name )as temp);


#---------------------------------------------------------------------------------------------------------------------

#8:  List the names of each technician, along with the number of hours the technician has spent on appointments and the amount of money billed for the technician’s hours.

select tech_id, first_name, last_name ,  sum(duration) as Total_time, sum(price) as Total_Billed
from technician
join appointments on tech_id=techid
join appointment_srvs on appointment_id = appointmentid
group by tech_id;

#--------------------------------------------------------------------------------------------------------------------

#9: List the name and ZIP code for all customers who have spent more than $500 (this could be spent over several different appointments, not just a single appointment).

SELECT		zip
FROM		customers
JOIN		appointments ON custid = customer_id
JOIN		appointment_srvs ON appointment_id = appointmentid
GROUP BY	customer_id
HAVING		sum(price) > 500; 

#----------------------------------------------------------------------------------------------------------------------

#10: . Show the ZIP code where the largest number of appointments were (i.e., the highest count of appointments for customers located in a specific ZIP code).

SELECT		temp.ZIP 
FROM		(
			SELECT 		zip ,count(appointment_Id) AS appointment_count
			FROM 		customers
			JOIN 		appointments ON custid = customer_id
			GROUP BY 	zip) as temp
WHERE		temp.appointment_count = ( 
										SELECT 	max(temp.appointment_count) 
                                        FROM	(
												SELECT 	 	zip ,count(appointment_Id) AS appointment_count
												FROM 		customers
												JOIN 		appointments ON custid = customer_id
												GROUP BY 	zip) as temp
                                                );
										
#--------------------------------------------------------- END -----------------------------------------------------------












