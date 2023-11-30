import pytest


# Test case for checking the status of the URL
@pytest.mark.dependency(name="test_url_status")
def test_url_status(url_response):
    assert url_response is not None, "Failed to get response."


@pytest.mark.dependency(depends=["test_url_status"])
def test_response_status(url_response):
    assert (
        url_response.status_code == 200
    ), f"Expected status code 200, but got {url_response.status_code}"


# Test case for checking the value returned in the response
@pytest.mark.dependency(depends=["test_response_status"])
def test_value_returned(url_response):
    assert url_response.json() > 0, "JSON response is empty or invalid"
