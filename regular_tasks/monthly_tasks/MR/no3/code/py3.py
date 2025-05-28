# Define the initial threshold value and threshold steps
thresholds = [10000, 5000, 3000, 1000]

final_output = []
total_unique_ssp = 0  # Initialize total_unique_ssp outside the loop

for threshold in thresholds:
    # Filter the data where `sum(imp)` is greater than the threshold
    filtered_threshold_df = df[df['sum(imp)'] > threshold]

    # 1. Get the total number of unique SSPs, excluding those with no `imp` above the threshold
    total_unique_ssp = filtered_threshold_df['ssp'].nunique()

    # 2. Group by `advertiser_id`, count the number of unique SSPs, and concatenate `child_ssp_id`
    grouped_df = filtered_threshold_df.groupby('advertiser_id').agg(
        num_unique_ssp=('ssp', 'nunique'),
        child_ssp_ids=('child_ssp_id', lambda x: ','.join(map(str, x)))
    ).reset_index()

    # 3. Filter the `advertiser_id` values where the count exceeds 80% of the total unique SSPs
    result_df = grouped_df[grouped_df['num_unique_ssp'] > 0.8 * total_unique_ssp]

    # Prepare the final output as a list of advertiser IDs
    final_output = result_df.to_dict(orient='records')

    if len(final_output) <= 20 and final_output:
        break

# Print the results
print(f"Total number of unique SSPs (excluding those with no imp above final threshold): {total_unique_ssp}\n")
print(f"Final threshold value for sum(imp): {threshold}\n")
print("Advertiser IDs where the number of SSPs used exceeds 80% of the total unique SSPs:\n")
if not final_output:
    print("No advertiser_id meets the criteria.")
else:
    for row in final_output:
        print(f"advertiser_id: {row['advertiser_id']}, child_ssp_ids: {row['child_ssp_ids']}")

    # Print only the list of advertiser_id
    advertiser_id_list = [row['advertiser_id'] for row in final_output]
    print("\nList of advertiser_id:", advertiser_id_list)