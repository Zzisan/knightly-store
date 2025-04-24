Rails.configuration.stripe = {
  # Your Stripe test API keys
  publishable_key: 'pk_test_51RHJqGP6HvWxJyJpnZzpJCCPF3JjVrfGmXSzYEBGoYVScccBYEcsVEcv9AuSFCUdz6xca1IdjfjNT1BMs8PaueMz00WqxsslN3',
  secret_key: 'sk_test_51RHJqGP6HvWxJyJpXIZpWSK5na743GBELF7wv1j4i5C9kkPlMDB0AAkvdg6Ut4w2VCTUyvZfSNVmIdYzYMNWNBYV00pufKv8nK'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
