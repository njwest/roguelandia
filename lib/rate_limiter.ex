defmodule RateLimiter do
  require Logger

  def check_rate(email, ip) do
    # Rate limit by email
    case Hammer.check_rate("login_attempt:#{email}", 300_000, 6) do
      {:allow, _count} ->
        # Rate limit by IP address
        case Hammer.check_rate("login_ip:#{ip}", 300_000, 20) do
          {:allow, _count} -> :allow
          {:deny, _limit} ->
            Logger.warning("Rate limit exceeded for IP: #{ip}, email: #{email}")
            :deny_ip
        end

      {:deny, _limit} -> :deny_email
    end
  end
end
