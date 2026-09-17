type StatusBadgeProps = {
  status: string;
};

const statusClassMap: Record<string, string> = {
  SUCCESS: "badge badge-success",
  RUNNING: "badge badge-info",
  VERIFYING: "badge badge-purple",
  FAILED: "badge badge-warning",
  FAILED_FINAL: "badge badge-danger",
  VALIDATING: "badge badge-neutral",
  PENDING: "badge badge-muted",
  REVIEW_REQUIRED: "badge badge-warning",
  DEFER_TO_MANUAL: "badge badge-muted",
  ALLOW: "badge badge-success",
  DENY: "badge badge-danger",
  QUEUED: "badge badge-info",
};

export default function StatusBadge({ status }: StatusBadgeProps) {
  return (
    <span className={statusClassMap[status] ?? "badge badge-muted"}>
      {status}
    </span>
  );
}