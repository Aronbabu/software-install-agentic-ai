import { api } from "./client";

export const getJobLedger = async (jobId: string) => {
  const response = await api.get(`/jobs/${jobId}/ledger`);
  return response.data;
};

export const getJobAuditTrail = async (jobId: string) => {
  const response = await api.get(`/jobs/${jobId}/audit-trail`);
  return response.data;
};