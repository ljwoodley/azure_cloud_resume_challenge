import pytest
import requests


def pytest_addoption(parser):
    parser.addoption("--url", action="store")


@pytest.fixture
def url(request):
    return request.config.getoption("--url")


@pytest.fixture
def url_response(url):
    """Fixture to get and return the response from a URL."""
    try:
        response = requests.get(url)
        return response
    except requests.exceptions.RequestException:
        pytest.fail(f"Failed to reach the URL: {url}")
