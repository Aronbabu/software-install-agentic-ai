import argparse

from app.db import SessionLocal
from app.knowledge.ingestion_service import (
    ingest_knowledge_article,
    ingest_sop_document,
)


def main():
    parser = argparse.ArgumentParser(
        description="Ingest SOP or knowledge documents into the database"
    )
    parser.add_argument(
        "--type",
        choices=["sop", "knowledge"],
        required=True,
        help="Document type to ingest",
    )
    parser.add_argument(
        "--file",
        required=True,
        help="Path to the input document file",
    )
    parser.add_argument(
        "--software",
        required=False,
        help="Software name associated with the document",
    )
    parser.add_argument(
        "--platform",
        required=False,
        help="Platform associated with the document (linux/windows)",
    )
    parser.add_argument(
        "--version",
        required=False,
        help="Software version for SOP ingestion",
    )
    parser.add_argument(
        "--owner",
        required=False,
        help="Owner of the SOP document",
    )
    parser.add_argument(
        "--title",
        required=False,
        help="Title for knowledge article ingestion",
    )

    args = parser.parse_args()
    db = SessionLocal()

    try:
        if args.type == "sop":
            if not args.software:
                raise ValueError("--software is required for SOP ingestion")
            if not args.platform:
                raise ValueError("--platform is required for SOP ingestion")

            sop = ingest_sop_document(
                db=db,
                file_path=args.file,
                software_name=args.software,
                platform=args.platform,
                software_version=args.version,
                owner=args.owner,
            )
            print(f"Ingested SOP successfully: id={sop.id}, name={sop.name}")

        elif args.type == "knowledge":
            article = ingest_knowledge_article(
                db=db,
                file_path=args.file,
                title=args.title or "Knowledge Article",
                software_name=args.software,
                platform=args.platform,
            )
            print(
                f"Ingested knowledge article successfully: id={article.id}, title={article.title}"
            )

    finally:
        db.close()


if __name__ == "__main__":
    main()