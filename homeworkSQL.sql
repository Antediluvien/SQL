-- DROP BUZZ LIGHTYEAR FROM THE LIST 

-- use sakila DB
USE sakila;


-- allow updates without the saftey requirement from primary key
SET SQL_SAFE_UPDATES = 0;

-- show the actor table, showing first and last name
Select first_name, last_name
from actor;

-- add column for actors full name 
alter table actor
add column actor_name varchar(50) after last_name;
select * from actor;

-- show table to verify column was added
select*from actor;

-- concatate first_name as last_name for column actor_name
select  
    first_name, 
    last_name,
    CONCAT(first_name,' ',last_name) as actor_name
from actor;

-- table is already uppercased but to uppercase a column (required in work) XXXXXXXXXXXXXXX
update actor set actor.actor_name = UPPER(`actor_name`);

-- 2A find ID number, first name and last name of an actor of whom you know only the first name, 
-- "Joe." What is one query would you use to obtain this information?
select *
from actor
where first_name 
like 'Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
select *
from actor
where last_name 
like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like '%LI%'
order by actor.last_name, actor.first_name,actor.actor_id, actor.actor_name,actor.last_update;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country
from country
where country 
in ('Afghanistan', 'Bangladesh','China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a 
-- 		column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference
-- 		between it and VARCHAR are significant).
alter table actor
add column description 
longblob after actor_name;
select * from actor;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor 
drop column description;
select * from actor; -- check to see if drop worked
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name 
from actor;
select last_name, 
count(*) c 
from actor 
group by last_name 
having c = 1 or c>1;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least 
-- 		two actors
select last_name, 
count(*) c 
from actor 
group by last_name 
having c>1;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
select *
from actor
where actor_name 
like '%groucho%';
update actor 
set first_name='HARPO' 
where last_name = 'WILLIAMS';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a 
-- single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
select *
from actor
where first_name 
like '%groucho%';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
--  ADD CITY AND POSTAL CODE
create table address_1 ( -- changed it to address_1 so there was no confusion in further queries
    address_1_id smallint(5) auto_increment not null,-- unassigned data type, auto increment, primary key
    address_1 varchar(50) not null,
    address_2 varchar(50) not null,
    district varchar(20) not null,
    city_id smallint(5) not null,
    postal_code varchar(10) not null,
    phone varchar(20) not null,
    location geometry,
    last_update timestamp,
    primary key (address_1_id)
);

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html



-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name,address.address
from staff
join address  -- default is inner join when only typing join
on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select*from staff;
select*from payment;
select staff.first_name, staff.last_name, 
sum(payment.amount) 
as 'total'
from staff 
left join payment 
on staff.staff_id = payment.staff_id
group by staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select* from film_actor;
select* from film;

select film.title, 
count(film_actor.actor_id) 
as 'total'
from film
left join film_actor 
on film.film_id = film_actor.film_id
group by film.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select *
from film
where title Like 'Hunch%';
select * 
from inventory
where film_id = 439; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers 
-- alphabetically by last name:
select *
from payment;
select *
from customer;
select customer.first_name, customer.last_name, 
sum(payment.amount) as 'total'
from customer 
left join payment 
on customer.customer_id = payment.customer_id
group by customer.first_name, customer.last_name
order by customer.last_name;

--     ![Total amount paid](Images/total_payment.png)

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with 
-- the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K 
-- and Q whose language is English.
select title
from film
where (title 
		like 'K%' 
        or title 
        like 'Q%') 
			and language_id=(
            select language_id 
            from language where name='English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name
from actor
where actor_id
	in (select actor_id 
		from film_actor 
		where film_id 
		in (select film_id 
			from film 
			where title='ALONE TRIP'));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of 
-- all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email 
from customer
join address
on (customer.address_id = address.address_id)
join city 
on (address.city_id=city.city_id)
join country 
on (city.country_id=country.country_id);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify 
-- all movies categorized as family films.
select film.title from film
where film_id in
	(select film_id 
    from film_category
	where category_id in
		(select category_id 
        from category
		where name like 'Family'));



-- 7e. Display the most frequently rented movies in descending order. ADD ORDER by
select*from rental;
select*from inventory;
select title, 
count(film.film_id) AS 'Count_of_Rented_Movies'
from  film
join inventory 
on (film.film_id= inventory.film_id)
join rental
on (inventory.inventory_id=rental.inventory_id)
group by title 
order by Count_of_Rented_Movies desc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select*from staff;
select * from payment;
select staff.store_id, 
sum(payment.amount) 
from payment
join staff 
on (payment.staff_id=staff.staff_id)
group by store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
Select*from store;
select*from city;
select*from country;
select store_id, city, country 
from store
join address 
on (store.address_id=address.address_id)
join city  
on (address.city_id=city.city_id)
join country  
on (city.country_id=country.country_id);
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;
select * from payment;

select category.name as 'Top Five', 
sum(payment.amount) 
from category
join film_category 
on (film_category.category_id = category.category_id)
join inventory 
on(inventory.film_id = film_category.film_id)
join rental 
on(rental.inventory_id = inventory.inventory_id)
join payment 
on (rental.rental_id = payment.rental_id)
group by name
order by sum(payment.amount) desc
limit 5;



-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to 
-- create a view.
create view TopFive as
select category.name as 'Top Five', 
sum(payment.amount) 
from category
join film_category 
on (film_category.category_id = category.category_id)
join inventory 
on(inventory.film_id = film_category.film_id)
join rental 
on(rental.inventory_id = inventory.inventory_id)
join payment 
on (rental.rental_id = payment.rental_id)
group by name
order by sum(payment.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from Topfive;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view TopFive;