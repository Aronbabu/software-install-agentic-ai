type StatusBadgeProps = {
  status: string;
};

export default function StatusBadge({
  status,
}: StatusBadgeProps) {

  const styles: Record<string, string> = {
    SUCCESS: "green",
    RUNNING: "blue",
    VERIFYING: "purple",
    FAILED: "orange",
    FAILED_FINAL: "red",
    VALIDATING: "gold",
    PENDING: "gray",
  };

  return (
    <span
      style={{
        backgroundColor: styles[status] || "gray",
        color: "white",
        padding: "4px 8px",
        borderRadius: "4px",
        fontWeight: "bold",
      }}
    >
      {status}
    </span>
  );
}