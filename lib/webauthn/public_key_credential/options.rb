# frozen_string_literal: true

require "securerandom"

module WebAuthn
  class PublicKeyCredential
    class Options
      include CamelizeHelper

      CHALLENGE_LENGTH = 32

      attr_reader :timeout, :extensions, :relying_party

      def initialize(timeout: nil, extensions: nil, relying_party: WebAuthn.configuration.relying_party)
        @relying_party = relying_party
        @timeout = timeout || default_timeout
        @extensions = default_extensions.merge(extensions || {})
      end

      def challenge
        encoder.encode(raw_challenge)
      end

      # Argument wildcard for Ruby on Rails controller automatic object JSON serialization
      def as_json(*)
        deep_camelize_keys(to_hash)
      end

      private

      def to_hash
        hash = {}

        attributes.each do |attribute_name|
          value = send(attribute_name)

          if value.respond_to?(:as_json)
            value = value.as_json
          end

          if value
            hash[attribute_name] = value
          end
        end

        hash
      end

      def attributes
        [:challenge, :timeout, :extensions]
      end

      def encoder
        relying_party.encoder
      end

      def raw_challenge
        @raw_challenge ||= SecureRandom.random_bytes(CHALLENGE_LENGTH)
      end

      def default_timeout
        relying_party.credential_options_timeout
      end

      def default_extensions
        {}
      end

      def as_public_key_descriptors(ids)
        Array(ids).map { |id| { type: TYPE_PUBLIC_KEY, id: id } }
      end
    end
  end
end
