# TEST SUBMISSION FOR GSoC'25 ECOTOURISM

## EASY TASK

It plots the occurrence data in Australia from the Atlas of Living Australia using `galah` package. It creates a plot of the map of Australia using `ggplot2` and `ggspatial` package.

The plot looks like the following:-

![RPlot](./images/Rplot.png)

## MEDIUM TASK

### Overview
In this test we analyze platypus sightings in Victoria, Australia, and retrieve weather data (temperature and precipitation) from the nearest weather station located in the **densest platypus sighting area**.

### Methodology
#### 1. **Plotting Platypus Occurrences**
We use the **galah R package** to obtain platypus occurrence records for the year **2024** and plot them on a map of Australia.

#### 2. **Finding the Central Location**
Using **Google**, I determined a central coordinate of Victoria, Australia:
   - **Latitude:** -36.9848
   - **Longitude:** 143.3906

To ensure sufficient coverage, we define a **radius of 300 km**, based on the approximate area calculation:

![Equation](https://latex.codecogs.com/svg.image?\text{radius}=\sqrt{\frac{227,444\text{km}^2}{\pi}}\approx&space;270\text{km})

Thus, a **300 km radius** is used as a **safe parameter**.

#### 3. **Density Estimation (KDE Approach)**
We apply **Kernel Density Estimation (KDE)** to find the **most densely populated platypus sighting area**. This area is marked in **purple** on the map.

#### 4. **Finding the Nearest Weather Station**
The nearest weather station to this dense platypus region is identified at:
   - **Latitude:** -37.733
   - **Longitude:** 145.1
   - **Marked in Green** on the map.

#### 5. **Retrieving Weather Data**
Using the **GSODR package**, we retrieve **daily temperature and precipitation data** for **2024** from this weather station.
Additionally, we extract **PRCP_ATTRIBUTES**, which indicate the type of precipitation reports received:

| Code | Meaning |
|------|---------|
| A | 1 report of 6-hour precipitation amount |
| B | Summation of 2 reports of 6-hour precipitation amount |
| C | Summation of 3 reports of 6-hour precipitation amount |
| D | Summation of 4 reports of 6-hour precipitation amount |
| E | 1 report of 12-hour precipitation amount |
| F | Summation of 2 reports of 12-hour precipitation amount |
| G | 1 report of 24-hour precipitation amount |
| H | Station reported ‘0’ precipitation but recorded precipitation in hourly observations (possibly a trace) |
| I | No precipitation reported, but it may have occurred |

### Results
The final map generated shows:
- **Blue Dots**: Individual platypus sightings.
- **Purple Region**: Densest platypus sighting area (KDE approach).
- **Green Dot**: Nearest weather station to the densest platypus sighting area.

![Platypus Sightings and Weather Station](./images/map.png)