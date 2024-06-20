defmodule RateLimiter do
  require Logger
  alias ExRated, as: RateLimiter

  @email_request_limit 6
  @ip_request_limit 100
  @time_window 300_000 # 5 minutes

  def check_rate(conn, email) do
    ip = ConnTools.get_ip(conn)

    with :ok <- check_rate_limit_email(email),
         :ok <- check_rate_limit_ip(ip) do
      :allow
    else
      :deny_email ->
        Logger.warning("Rate limit exceeded for email: #{email}")
        :deny_email

      :deny_ip ->
        Logger.warning("Rate limit exceeded for IP: #{ip}, email: #{email}")
        :deny_ip
    end
  end

  defp check_rate_limit_email(email) do
    case RateLimiter.check_rate("login_attempt:#{email}", @time_window, @email_request_limit) do
      {:ok, _count} -> :ok
      {:error, _limit} -> :deny_email
    end
  end

  defp check_rate_limit_ip(ip) do
    case RateLimiter.check_rate("login_ip:#{ip}", @time_window, @ip_request_limit) do
      {:ok, _count} -> :ok
      {:error, _limit} -> :deny_ip
    end
  end
end
