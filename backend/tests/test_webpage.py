from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
import pytest


@pytest.mark.dependency(name="test_url_status")
def test_url_status(url_response):
    assert url_response is not None, "Failed to get response."


@pytest.mark.dependency(depends=["test_url_status"])
def test_visitor_count(url):
    chrome_options = Options()
    option_list = ['--no-sandbox', '--disable-dev-shm-usage',
                   '--headless', '--disable-gpu']

    for option in option_list:
        chrome_options.add_argument(option)

    with webdriver.Chrome(options=chrome_options) as driver:
        driver.get(url)
        try:
            # Wait until the value in the 'counter' element is a digit
            WebDriverWait(driver, 10).until(
                lambda d: d.find_element(By.ID, "counter").text.isdigit()
            )
        except TimeoutException:
            assert False, "Visitor count not found"
