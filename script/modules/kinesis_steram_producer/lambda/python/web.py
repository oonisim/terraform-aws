"""
Web page generator
"""

def kinesis_producer(url):
    """Generate a web page to upload a file.
    Args:
        url: URL to upload the file
    Returns:
        web page generated
    """
    page = """
        <html><body>
        {0}
        </body></html>
    """

    return page.format(url)