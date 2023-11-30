import azure.functions as func
import json


def main(
    req: func.HttpRequest,
    InputDocument: func.DocumentList,
    OutputDocument: func.Out[func.Document],
) -> func.HttpResponse:
    # Check if document exists
    if not InputDocument:
        # Create the document on the first run
        new_data = {"id": "1", "count": 1}
        OutputDocument.set(func.Document.from_dict(new_data))
        response_body = new_data["count"]
    else:
        # Access the document for reading
        current_data = InputDocument[0]
        # Increment the count
        current_data["count"] += 1
        response_body = current_data["count"]

        # Prepare the document for writing back to Cosmos DB
        updated_document = func.Document.from_dict(current_data)
        OutputDocument.set(updated_document)

    return func.HttpResponse(
        json.dumps(response_body),
        status_code=200,
        headers={"Content-Type": "application/json"},
    )
