import { api } from "./client";

export const getJob = async (
  jobId: string
) => {

  const response =
    await api.get(
      `/jobs/${jobId}`
    );

  return response.data;
};

export const getJobProgress = async (
  jobId: string
) => {

  const response =
    await api.get(
      `/jobs/${jobId}/progress`
    );

  return response.data;
};