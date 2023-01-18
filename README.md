# Portfolio Project 3 - SQL - COVID-19 Data

Welcome to my third portfolio project. In this data cleaning and analysis project, I analyse a COVID-19 dataset using various SQL queries.

There is 1 project file (SQL) and 2 data table files (2 CSVs) in this repository.

Original dataset: "Coronavirus Pandemic (COVID-19)" (Licence CC-BY-4.0) published online at https://ourworldindata.org/covid-deaths

Citation and thanks to authors and contributors to the dataset: Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina and Max Roser (2020).

**Project Guide**

I first split the original dataset into 2 tables - one containing various COVID deaths data (covid_deaths), and the other containing various COVID vaccinations data (covid_vaccinations). This enabled me to demonstrate JOINs on the 2 tables.

I then run various analysis queries and also create temp tables and views.

Some of the data wouldn't import as the data type that it should be, therefore I have also made use of SQL's CAST function, which allows me to cast the data into my desired data type for the purposes of my querying and analysis.
