import geopandas as gpd
import pandas as pd

# Load the shapefile
gdf = gpd.read_file('../SA2_2021_AUST_SHP_GDA2020/SA2_2021_AUST_GDA2020.shp')

# Create a list to store all the centroid data with their names
full_data = []


def compute_centroid():
    for i in range(0, 2473):

        # Extracts the SA2 region POLYGON geometry
        region = gdf.geometry[i]

        if region is None or region.is_empty:  # Adds NA to missing geometries centroids
            print(f"Skipping index {gdf.SA2_NAME21[i]} due to missing geometry.")
            x = "NA"
            y = "NA"
            full_data.append({"name": gdf.SA2_NAME21[i], "lat": x, "long": y})
            continue

        x = region.centroid.x
        y = region.centroid.y

        full_data.append({"name": gdf.SA2_NAME21[i], "lat": x, "long": y})


# Saves the Coords dataset to a CSV file
def save_to_csv():
    """ Save final dataset to CSV """
    df = pd.DataFrame(full_data, columns=["name", "lat", "long"])
    df.to_csv("./generated_files/sa2_regions.csv", index=False, encoding="utf-8")
    print("Data saved to 'sa2_regions.csv'")


# Merges the CSV with Coords and the original CSV given in the problem
def merge():
    trips_df = pd.read_csv("domestic_trips_2023-10-08.csv")

    # Load the SA2 region dataset
    sa2_df = pd.read_csv("sa2_regions.csv")

    # Merge the datasets based on region names
    merged_df = trips_df.merge(sa2_df, how="left", left_on="region", right_on="name")

    # Drop the duplicate 'name' column (since 'region' already exists)
    merged_df.drop(columns=["name"], inplace=True)
    merged_df.drop(columns=["Misc"], inplace=True)

    # Save the updated dataset
    merged_df.to_csv("./generated_files/domestic_trips_with_coords.csv", index=False, encoding="utf-8")

    print("Merged dataset saved as 'domestic_trips_with_coords.csv'.")


compute_centroid()
save_to_csv()
merge()