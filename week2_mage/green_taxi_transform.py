if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

import re

@transformer
def transform(data, *args, **kwargs):
    """
    Template code for a transformer block.

    Add more parameters to this function if this block has multiple parent blocks.
    There should be one parameter for each output variable from each parent block.

    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """
    # Specify your transformation logic here

    def camel_to_snake(name):
        """
        Convert a string from CamelCase to snake_case.
        """
        name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
        return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()


    # 1) Remove rows where the passenger count is equal to 0 and the trip distance is equal to zero.
    df = data[(data['passenger_count'] > 0) & (data['trip_distance'] > 0)]

    # 2) Create a new column lpep_pickup_date by converting lpep_pickup_datetime to a date.
    df['lpep_pickup_date'] = df['lpep_pickup_datetime'].dt.date

    # 3) Rename columns in Camel Case to Snake Case
    #df.columns = df.columns.str.replace("([a-z])([A-Z]{2,})", r"\1_\2")
    df.columns = [camel_to_snake(column) for column in df.columns]

    return df


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output['vendor_id'].isin([1,2]).all(), "VendorID is not one of the existing values [1, 2]"
    assert (output['passenger_count'] > 0).all(), "There are rows with passenger_count <= 0"
    assert (output['trip_distance'] > 0).all(), "There are rows with trip_distance <= 0"

   