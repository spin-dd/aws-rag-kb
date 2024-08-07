from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.dialects.postgresql import UUID
from pgvector.sqlalchemy import Vector
from sqlalchemy import String, JSON, Text
from sqlalchemy.sql.schema import Column


class Base(DeclarativeBase):
    pass


class BedrockKnowlegeBase(Base):
    """
    https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
    """

    __abstract__ = True

    id: Mapped[UUID] = mapped_column(UUID, primary_key=True, comment="primary_key_field")
    embedding: Mapped[Vector] = mapped_column(Vector(1536), comment="vector_field")
    bedrock_meta: Mapped[JSON] = mapped_column(JSON, comment="metadata_field")
    chunks: Mapped[str] = mapped_column(Text, comment="text_field")

    @classmethod
    def get_vector_field(cls) -> Column:
        return next(filter(lambda i: i.comment == "vector_field", cls.__table__.columns))

    @classmethod
    def get_field_mapping(cls) -> Column:
        # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base#field_mapping
        return dict((i.comment, i.name) for i in cls.__table__.columns if i.comment)


class Knowlege(BedrockKnowlegeBase):
    __tablename__ = "kb"
    __table_args__ = {"schema": "bedrock"}

    categories: Mapped[str] = mapped_column(String(256), nullable=True)
    document: Mapped[str] = mapped_column(String(256), nullable=True)
    doc_class: Mapped[str] = mapped_column(String(256), nullable=True)
