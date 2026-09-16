from app.db.session import SessionLocal
from app.scripts.retrieval_service import retrieve_relevant_chunks

db = SessionLocal()
try:
    results = retrieve_relevant_chunks(
        db=db,
        query_text="How do I install curl on linux and verify it?",
        software_name="curl",
        platform="linux",
        k=3,
    )
    for row in results:
        print(row)
finally:
    db.close()